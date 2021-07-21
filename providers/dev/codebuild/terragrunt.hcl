terraform {
  source = "../../../modules//codebuild"
  extra_arguments "vars" {
    arguments = [
      "-var-file=${get_terragrunt_dir()}/../credentials.tfvars",
    ]

    commands = get_terraform_commands_that_need_vars()
  }
}

include {
  path = find_in_parent_folders()
}

dependency "ecr" {
  config_path = "../ecr"
  skip_outputs = true
}

dependency "cluster" {
  config_path = "../ecs-cluster"
  mock_outputs = {
    vpc_id          = "vpc-000000000000"
    subnets = ["subnet-00000000000", "subnet-111111111111"]
  }
}

inputs = {
    vpc_id = dependency.cluster.outputs.vpc_id
    subnets = dependency.cluster.outputs.subnets
    build_spec_file = "providers/dev/buildspec.yml"
}
