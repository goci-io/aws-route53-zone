
output "zone_id" {
  value = join("", aws_route53_zone.dns_zone.*.zone_id)
}

output "public_zone_id" {
  value = var.enabled && local.use_public ? local.public_zone_id : ""
}

output "name_servers" {
  value = flatten(aws_route53_zone.dns_zone.*.name_servers)
}

output "domain_name" {
  value = trim(join("", aws_route53_zone.dns_zone.*.name), ".")
}

output "certificate_arn" {
  value = join("", aws_acm_certificate_validation.default.*.certificate_arn)
}

output "certificate_validation_options" {
  value = aws_acm_certificate.default.*.domain_validation_options
}
