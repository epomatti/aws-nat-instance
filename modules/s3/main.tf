locals {
  random_affix = random_string.random_suffix.result
  file_path    = "${path.module}/usg/jammy-server-level1.xml"
}

resource "random_string" "random_suffix" {
  length  = 3
  special = false
  upper   = false
}

resource "aws_s3_bucket" "main" {
  bucket        = "bucket-natinstance-ubuntu-pro-usg-${local.random_affix}"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "tailor" {
  bucket = aws_s3_bucket.main.id
  key    = "tailor.xml"
  source = local.file_path
  etag   = filemd5(local.file_path)
}
