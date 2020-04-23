
output "zone_id" {
  value = var.enabled ? aws_route53_zone.dns_zone.0.zone_id : ""
}

output "public_zone_id" {
  value = var.enabled && local.use_public ? local.public_zone_id : ""
}

output "name_servers" {
  value = var.enabled ? aws_route53_zone.dns_zone.0.name_servers : []
}

output "domain_name" {
  value = local.fqdn
}

output "certificate_arn" {
  value = var.enabled ? join("", aws_acm_certificate.default.*.arn) : ""
}

output "certificate_validation_options" {
  value = var.enabled ? aws_acm_certificate.default.*.domain_validation_options : []
}
