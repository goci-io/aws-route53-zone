
output "zone_id" {
  value = aws_route53_zone.dns_zone.0.zone_id
}

output "public_zone_id" {
  value = local.use_public ? local.public_zone_id : ""
}

output "name_servers" {
  value = aws_route53_zone.dns_zone.0.name_servers
}

output "domain_name" {
  value = local.fqdn
}

output "certificate_arn" {
  value = join("", aws_acm_certificate.default.*.arn)
}

output "certificate_validation_options" {
  value = aws_acm_certificate.default.*.domain_validation_options
}
