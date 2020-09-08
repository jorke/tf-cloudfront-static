terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias = "useast"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "this" {
  bucket = var.domain

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  website {
    index_document = var.index_document
    error_document = ""
  }

  tags = var.tags

  force_destroy = true
}


data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.this.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.this.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.this.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = "${aws_s3_bucket.this.id}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"
}
