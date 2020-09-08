resource "aws_route53_zone" "this" {
  name = var.domain
  tags = var.tags
  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_route53_record" "cf_alias" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}

resource "aws_route53_record" "cf_alias_AAAA" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.domain
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}
