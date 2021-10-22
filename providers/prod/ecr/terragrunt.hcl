terraform {
  source = "../../../modules//ecr"
}

include {
  path = find_in_parent_folders()
}
