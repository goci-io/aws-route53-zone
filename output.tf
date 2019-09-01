
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
  value = module.acm.arn
}

output "certificate_validation_options" {
  value = module.acm.domain_validation_options
}
