
locals {
  prod_stages  = ["prod", "production", "main"]
  tld          = element(local.domain_parts, length(local.domain_parts) - 1)
  domain_parts = var.parent_domain_name == "" ? [var.tld] : split(".", var.parent_domain_name)
  fqdn         = var.domain_name == "" ? format("%s.%s", module.label.id, local.tld) : var.domain_name
  label_order  = contains(local.prod_stages, var.stage) ? ["name", "attributes", "namespace"] : ["name", "stage", "attributes", "namespace"]
}

module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0"
  namespace   = var.namespace
  stage       = var.stage
  attributes  = var.attributes
  tags        = var.tags
  name        = var.name
  label_order = local.label_order
  delimiter   = "."
}

resource "aws_route53_zone" "dns_zone" {
  provider = aws.member_account
  name     = local.fqdn
  tags     = module.label.tags
}

data "aws_route53_zone" "parent" {
  count     = var.parent_domain_name == "" ? 0 : 1
  name      = var.parent_domain_name
}

resource "aws_route53_record" "ns" {
  count           = var.parent_domain_name == "" ? 0 : 1
  zone_id         = element(data.aws_route53_zone.parent.*.zone_id, 0)
  name            = local.fqdn
  allow_overwrite = true
  type            = "NS"
  ttl             = 300
  records         = [
    aws_route53_zone.dns_zone.name_servers.0,
    aws_route53_zone.dns_zone.name_servers.1,
    aws_route53_zone.dns_zone.name_servers.2,
    aws_route53_zone.dns_zone.name_servers.3,
  ]
}

module "acm" {
  source                            = "git::https://github.com/cloudposse/terraform-aws-acm-request-certificate.git?ref=tags/0.4.0"
  subject_alternative_names         = distinct(concat([format("*.%s", local.fqdn)], var.certificate_alternative_names))
  enabled                           = var.certificate_enabled
  domain_name                       = local.fqdn
  process_domain_validation_options = true
  wait_for_certificate_issued       = true
  providers                         = {
    aws = aws.member_account
  }
}
