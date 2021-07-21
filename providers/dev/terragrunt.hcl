remote_state {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "terraform-nodeapp-ecs"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks-nodeapp"
    profile        = "default"
  }
}

# Version Locking
## tfenv exists to help developer experience for those who use tfenv
## it will automatically download and use this terraform version
generate "tfenv" {
  path              = ".terraform-version"
  if_exists         = "overwrite"
  disable_signature = true

  contents = <<EOF
0.14.7
EOF
}

terraform_version_constraint = "0.14.7"

terragrunt_version_constraint = ">= 0.26.7"

terraform {
  after_hook "remove_lock" {
    commands = [
      "apply",
      "console",
      "destroy",
      "import",
      "init",
      "plan",
      "push",
      "refresh",
    ]

    execute = [
      "rm",
      "-f",
      "${get_terragrunt_dir()}/.terraform.lock.hcl",
    ]

    run_on_error = true
  }
}
inputs = {
  remote_state_bucket = "terraform-nodeapp-ecs"
  environment = "dev"
  app_name = "flaskapp"
  image_tag = "0.0.1"
  repo_url = "https://github.com/olap74/terragunt-flask"
  aws_profile = "default"
  aws_account = "695741482326"
  aws_region = "eu-west-1"
  branch_pattern = "^refs/heads/develop$"
  git_trigger_event = "PUSH"
}
