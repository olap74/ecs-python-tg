terraform {
  source = "../../../modules//ecr"
}

locals {
  secrets = read_terragrunt_config(find_in_parent_folders("secrets.hcl"))
}

include {
  path = find_in_parent_folders()
}

inputs = local.secrets.inputs
