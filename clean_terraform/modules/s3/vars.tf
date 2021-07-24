variable "bucket_name" {
  type        = string
  description = "The name of the bucket"
}

variable "bucket_description" {
  type        = string
  default     = ""
  description = "S3 Bucket for saving terraform state"
}
