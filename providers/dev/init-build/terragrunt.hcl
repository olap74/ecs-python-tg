terraform {
  source = "../../../modules//init-build"
}

locals {
  secrets = read_terragrunt_config(find_in_parent_folders("secrets.hcl"))
}

include {
  path = find_in_parent_folders()
}

dependency "ecr" {
  config_path = "../ecr"
  skip_outputs = true
}

inputs = merge(
  local.secrets.inputs,
  {
    working_dir = "${get_terragrunt_dir()}/../../../app"
  }
)
