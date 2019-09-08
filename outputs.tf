
output "zone_id" {
  value = aws_route53_zone.dns_zone.zone_id
}

output "name_servers" {
  value = aws_route53_zone.dns_zone.name_servers
}

output "domain_name" {
  value = local.fqdn
}

output "certificate_arn" {
  value = aws_acm_certificate.default.arn
}

output "certificate_validation_options" {
  value = aws_acm_certificate.default.*.domain_validation_options
}