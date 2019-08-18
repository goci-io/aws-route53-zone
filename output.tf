
output "zone_id" {
  value = aws_route53_zone.dns_zone.zone_id
}

output "name_servers" {
  value = aws_route53_zone.dns_zone.name_servers
}

output "domain_name" {
  value = local.fqdn
}