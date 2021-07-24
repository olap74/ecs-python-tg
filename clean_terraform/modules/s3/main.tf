resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  
  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [tags,tags_all]
  }

  tags = {
    Name = var.bucket_description
  }
}
