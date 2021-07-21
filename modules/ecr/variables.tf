variable "aws_region" {
  description = "aws region"
}

variable "aws_profile" {
  description = "aws profile"
}

variable "remote_state_bucket" {}

variable "environment" {
  type = string
}

variable "app_name" {
  type = string
}

locals {
  repository_name = format("%s-%s", var.app_name, var.environment)
}
