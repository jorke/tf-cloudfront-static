resource "aws_acm_certificate" "this" {
  provider    = aws.useast
  domain_name = var.domain
  subject_alternative_names = var.aliases

  validation_method = "DNS"
  tags              = var.tags
  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["subject_alternative_names"]
  }
}

resource "aws_acm_certificate_validation" "this" {
  provider        = aws.useast
  certificate_arn = aws_acm_certificate.this.arn
  validation_record_fqdns = [
    for r in aws_route53_record.validation :
    r.fqdn
  ]
}

resource "aws_route53_record" "validation" {
  depends_on = [aws_acm_certificate.this]

  for_each = {
    for d in aws_acm_certificate.this.domain_validation_options: d.domain_name => {
      name   = d.resource_record_name
      record = d.resource_record_value
      type   = d.resource_record_type
    }
  }
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type

  zone_id         = aws_route53_zone.this.id
  ttl             = 60
  allow_overwrite = true
}
