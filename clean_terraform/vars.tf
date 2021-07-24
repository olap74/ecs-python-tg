variable "bucket_name" {
  type        = string
  description = "S3 Bucket name"
  default     = "flaskapp-dev-eu-west-1"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_profile" {
    default = "default"
}

variable "environment" {
    type = string
    default = "dev"
}

variable "app_name" {
    type = string
    default = "flaskapp"
}

variable "image_tag" {
    type = string
}

variable "aws_account" {
    type=string
}

variable "github_oauth_token" {
    type=string
    default = ""
}

variable "repo_url" {
    type = string
    default = ""
}

variable "branch_pattern" {
    type = string
    default = ""
}

variable "git_trigger_event" {
    type = string
    default = ""
}

variable "app_count" {
    default = 1
}
