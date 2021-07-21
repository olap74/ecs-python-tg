resource "null_resource" "build" {
  provisioner "local-exec" {
    command = "make build"
    working_dir = var.working_dir
    environment = {
        TAG = var.image_tag
        REGISTRY_ID = data.aws_caller_identity.current.account_id
        REPOSITORY_REGION = var.aws_region
        APP_NAME = var.app_name
        ENV_NAME = var.environment
    }
  }
}
