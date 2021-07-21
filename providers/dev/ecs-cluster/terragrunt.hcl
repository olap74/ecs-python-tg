terraform {
  source = "../../../modules//cluster"
}

locals {
  secrets = read_terragrunt_config(find_in_parent_folders("secrets.hcl"))
}

include {
  path = find_in_parent_folders()
}

dependencies {
    paths = ["../init-build"]
}

dependency "ecr" {
    config_path = "../ecr"
    mock_outputs = {
      ecr_repository_url = "000000000000.dkr.ecr.eu-west-1.amazonaws.com/image"
  }
}

inputs = merge(
  local.secrets.inputs,
  {
    ecr_repository_url = dependency.ecr.outputs.ecr_repository_url
  }
)
