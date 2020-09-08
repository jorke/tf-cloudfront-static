output "s3_bucket" {
  value = aws_s3_bucket.this
}

output "name_servers" {
  value = aws_route53_zone.this.name_servers
}
