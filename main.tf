
locals {
  prod_stages  = ["prod", "production", "main"]
  tld          = element(local.domain_parts, length(local.domain_parts) - 1)
  domain_parts = var.parent_domain_name == "" ? [var.tld] : split(".", var.parent_domain_name)
  fqdn         = var.domain_name == "" ? format("%s.%s", module.label.id, local.tld) : var.domain_name
  vpc_ids      = var.vpc_module_state == "" ? var.zone_vpcs : [data.terraform_remote_state.vpc[0].outputs.vpc_id]
  label_order  = contains(local.prod_stages, var.stage) ? ["name", "attributes", "namespace"] : ["name", "stage", "attributes", "namespace"]
}

data "terraform_remote_state" "vpc" {
  count   = var.vpc_module_state == "" ? 0 : 1
  backend = "s3"

  config = {
    bucket = var.tf_bucket
    key    = var.vpc_module_state
  }
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

  dynamic "vpc" {
    iterator = zone
    for_each = local.vpc_ids

    content {
      vpc_id = zone.value
    }
  }
}

data "aws_route53_zone" "parent" {
  provider     = aws.parent_account
  count        = var.parent_domain_name == "" ? 0 : 1
  name         = format("%s.", var.parent_domain_name)
  private_zone = var.is_parent_private_zone
}

resource "aws_route53_record" "ns" {
  provider        = aws.parent_account
  count           = var.parent_domain_name == "" ? 0 : 1
  zone_id         = element(data.aws_route53_zone.parent.*.zone_id, 0)
  name            = local.fqdn
  allow_overwrite = true
  type            = "NS"
  ttl             = 300
  records = [
    aws_route53_zone.dns_zone.name_servers.0,
    aws_route53_zone.dns_zone.name_servers.1,
    aws_route53_zone.dns_zone.name_servers.2,
    aws_route53_zone.dns_zone.name_servers.3,
  ]
}

resource "null_resource" "await_zone" {
  depends_on = [aws_route53_zone.dns_zone]
  triggers   = {
    domain_name = local.fqdn
  }
}

module "acm" {
  source                            = "git::https://github.com/cloudposse/terraform-aws-acm-request-certificate.git?ref=tags/0.4.0"
  subject_alternative_names         = distinct(concat([format("*.%s", local.fqdn)], var.certificate_alternative_names))
  domain_name                       = null_resource.await_zone.triggers.domain_name
  enabled                           = var.certificate_enabled
  process_domain_validation_options = true
  wait_for_certificate_issued       = true
  providers = {
    aws = aws.member_account
  }
}
