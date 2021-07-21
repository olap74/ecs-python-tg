variable "aws_region" {
  description = "aws region"
}

variable "aws_profile" {
  description = "aws profile"
}

variable "remote_state_bucket" {}

variable "image_tag" {
    type = string
}

variable "working_dir" {
    type = string
}

variable "app_name" {
    type = string
}

variable "environment" {
    type = string
}
