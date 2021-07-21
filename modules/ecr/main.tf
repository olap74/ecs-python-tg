resource "aws_ecr_repository" "ecr_repository" {
  name = local.repository_name
}
