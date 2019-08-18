terraform {
  required_version = ">= 0.12.1"
  backend "s3" {}
}

locals {
  tld          = element(local.domain_parts, length(local.domain_parts) - 1)
  domain_parts = var.parent_domain_name == "" ? [var.tld] : split(".", var.parent_domain_name)
  fqdn         = var.domain_name == "" ? format("%s.%s", module.label.id, local.tld) : var.domain_name
}

module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0"
  namespace   = var.namespace
  stage       = var.stage
  attributes  = var.attributes
  tags        = var.tags
  name        = var.name
  delimiter   = "."
  label_order = ["name", "stage", "attributes", "namespace"]
}

resource "aws_route53_zone" "dns_zone" {
  name = local.fqdn
  tags = module.label.tags
}

provider "aws" {
  alias   = "parent-zone-account"
  profile = var.aws_profile
}

data "aws_route53_zone" "parent" {
  count     = var.parent_domain_name == "" ? 0 : 1
  provider  = "aws.parent-zone-account"
  name      = var.parent_domain_name
}

resource "aws_route53_record" "ns" {
  provider        = "aws.parent-zone-account"
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
