data "aws_region" "current" {}

resource "aws_security_group" "codebuild_sg" {
  name        = "allow_vpc_connectivity"
  description = "Allow Codebuild connectivity to all the resources within our VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "import_source_credentials" {

  
  triggers = {
    github_oauth_token = var.github_oauth_token
  }

  provisioner "local-exec" {
    command = <<EOF
      aws --region ${data.aws_region.current.name} codebuild import-source-credentials \
                                                             --token ${var.github_oauth_token} \
                                                             --server-type GITHUB \
                                                             --auth-type PERSONAL_ACCESS_TOKEN
EOF
  }
}

# CodeBuild Project
resource "aws_codebuild_project" "project" {
  depends_on = [null_resource.import_source_credentials]
  name = local.codebuild_project_name
  description = local.description
  build_timeout = "120"
  service_role = aws_iam_role.role.arn

  artifacts {
    type = "NO_ARTIFACTS"
}

  environment {
    # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
    compute_type = "BUILD_GENERAL1_SMALL" # 7 GB memory
    # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
    image = "aws/codebuild/standard:4.0"
    type = "LINUX_CONTAINER"
    # The privileged flag must be set so that your project has the required Docker permissions
    privileged_mode = true

    environment_variable {
      name = "CI"
      value = "true"
    }
  }

  source {
    buildspec = var.build_spec_file
    type = "GITHUB"
    location = var.repo_url
    git_clone_depth = 1
    report_build_status = "true"
  }

  # Removed due using cache from ECR
  # cache {
  #   type = "LOCAL"
  #   modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  # }

  # https://docs.aws.amazon.com/codebuild/latest/userguide/vpc-support.html#enabling-vpc-access-in-projects
  # Access resources within our VPC
  // dynamic "vpc_config" {
  //   for_each = var.vpc_id == null ? [] : [var.vpc_id]
  //   content {
  //     vpc_id = var.vpc_id
  //     subnets = var.subnets
  //     security_group_ids = var.security_groups
  //   }
  // }
  vpc_config {
    vpc_id = var.vpc_id

    subnets = var.subnets

    security_group_ids = [ aws_security_group.codebuild_sg.id ]
  }
}

resource "aws_codebuild_webhook" "develop_webhook" {
  project_name = aws_codebuild_project.project.name

  # https://docs.aws.amazon.com/codebuild/latest/APIReference/API_WebhookFilter.html
  filter_group {
    filter {
      type = "EVENT"
      pattern = var.git_trigger_event
    }

    filter {
      type = "HEAD_REF"
      pattern = var.branch_pattern
    }
  }
}
