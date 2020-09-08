resource "aws_cloudfront_origin_access_identity" "this" {
  comment = var.domain
}

resource "aws_cloudfront_distribution" "this" {

  tags = var.tags

  aliases = concat([var.domain],var.aliases)

  origin {
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.this.bucket_regional_domain_name
    origin_path = ""

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }


  dynamic origin {
    for_each = var.other_endpoints

    content {
      domain_name = origin.value.endpoint
      origin_id   = origin.value.origin
      origin_path = origin.value.path
      custom_origin_config {
        http_port              = "80"
        https_port             = "443"
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = ["TLSv1.1", "TLSv1.2"]
      }
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.this.bucket_regional_domain_name

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    max_ttl                = 0
    default_ttl            = 0
  }

  dynamic ordered_cache_behavior {
    for_each = var.other_endpoints

    content {

      path_pattern     = ordered_cache_behavior.value.pattern
      allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = ordered_cache_behavior.value.origin

      forwarded_values {
        query_string = true

        cookies {
          forward = "all"
        }
        headers = [
          "Accept",
          "Authorization",
          "Origin",
          "Content-Type"
        ]
      }

      viewer_protocol_policy = "redirect-to-https"
      default_ttl            = 3600
      max_ttl                = 3600
      min_ttl                = 0
    }
  }

  price_class = "PriceClass_All"
  enabled     = true

  viewer_certificate {
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1_2016"
    acm_certificate_arn      = aws_acm_certificate.this.arn
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  retain_on_delete    = true
  is_ipv6_enabled     = true
  default_root_object = var.index_document
  wait_for_deployment = var.wait_for_deployment
}
