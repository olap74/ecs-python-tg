
module "s3_terraform_state" {
  source = "./modules/s3"
  bucket_name = var.bucket_name
}

module "ecr" {
    source = "../modules//ecr"
    aws_region = var.aws_region
    aws_profile = var.aws_profile
    remote_state_bucket = var.bucket_name
    environment = var.environment
    app_name = var.app_name
}

module "init-build" {
    source = "../modules//init-build"
    aws_region = var.aws_region
    aws_profile = var.aws_profile
    remote_state_bucket = var.bucket_name
    environment = var.environment
    app_name = var.app_name
    working_dir = "${path.root}/../app"
    image_tag = var.image_tag
}

module "ecs-cluster" {
    source = "../modules//cluster"
    aws_region = var.aws_region
    aws_profile = var.aws_profile
    remote_state_bucket = var.bucket_name
    environment = var.environment
    app_name = var.app_name
    image_tag = var.image_tag
    ecr_repository_url = module.ecr.ecr_repository_url
    taskdef_template = "${path.root}/../modules/cluster/cb_app.json.tpl"
    app_count = var.app_count
}

module "codebuild" {
    source = "../modules/codebuild"
    aws_region = var.aws_region
    aws_profile = var.aws_profile
    remote_state_bucket = var.bucket_name
    environment = var.environment
    app_name = var.app_name
    vpc_id = module.ecs-cluster.vpc_id
    subnets = module.ecs-cluster.subnets
    github_oauth_token = var.github_oauth_token
    repo_url = var.repo_url
    branch_pattern = var.branch_pattern
    git_trigger_event = var.git_trigger_event
    build_spec_file = "clean_terraform/config/buildspec.yml"
}
