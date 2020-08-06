
locals {
  prod_stages      = ["prod", "production", "main"]
  external_vpc_ids = distinct(keys(var.external_zone_vpcs))
  use_public       = length(local.vpc_ids) > 0 && var.create_public_zone
  tld              = element(local.domain_parts, length(local.domain_parts) - 1)
  domain_parts     = var.parent_domain_name == "" ? [var.tld] : split(".", var.parent_domain_name)
  fqdn             = var.domain_name == "" ? format("%s.%s", module.label.id, local.tld) : var.domain_name
  public_zone_id   = var.enabled ? local.use_public ? join("", aws_route53_zone.public_zone.*.zone_id) : aws_route53_zone.dns_zone.0.zone_id : ""
  public_ns        = var.enabled ? local.use_public ? flatten(aws_route53_zone.public_zone.*.name_servers) : aws_route53_zone.dns_zone.0.name_servers : []
  vpc_ids          = var.vpc_module_state == "" ? var.zone_vpcs : concat(var.zone_vpcs, data.terraform_remote_state.vpc.*.outputs.vpc_id)
  label_order      = contains(local.prod_stages, var.stage) && var.omit_prod_stage ? ["name", "attributes", "namespace"] : ["name", "stage", "attributes", "namespace"]
  tag_overwrites = {
    Name = format("ACM %s", var.name == "" ? local.fqdn : var.name)
  }

  subject_alternative_names      = distinct(concat([format("*.%s", local.fqdn)], var.certificate_alternative_names))
  domain_validation_options_list = var.certificate_enabled ? aws_acm_certificate.default.*.domain_validation_options : []
}

data "aws_region" "current" {}

data "terraform_remote_state" "vpc" {
  count   = ! var.enabled || var.vpc_module_state == "" ? 0 : 1
  backend = "s3"

  config = {
    bucket = var.tf_bucket
    key    = var.vpc_module_state
  }
}

module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  enabled     = var.enabled
  namespace   = var.namespace
  stage       = var.stage
  attributes  = var.attributes
  name        = var.name
  label_order = local.label_order
  tags        = merge(var.tags, local.tag_overwrites)
  delimiter   = "."
}

resource "aws_route53_zone" "dns_zone" {
  count    = var.enabled ? 1 : 0
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

resource "aws_route53_zone_association" "external_vpcs" {
  count      = var.enabled ? length(local.external_vpc_ids) : 0
  zone_id    = aws_route53_zone.dns_zone.0.zone_id
  vpc_id     = element(local.external_vpc_ids, count.index)
  vpc_region = lookup(var.external_zone_vpcs, local.external_vpc_ids[count.index], data.aws_region.current.name)
}

resource "aws_route53_zone" "public_zone" {
  count    = var.enabled && local.use_public ? 1 : 0
  tags     = merge(module.label.tags, { UtilityZone = "true" })
  name     = local.fqdn
}

data "aws_route53_zone" "parent" {
  provider     = aws.owner
  count        = ! var.enabled || var.parent_domain_name == "" ? 0 : 1
  name         = format("%s.", var.parent_domain_name)
  private_zone = var.is_parent_private_zone
}

resource "aws_route53_record" "ns" {
  provider        = aws.owner
  count           = ! var.enabled || var.parent_domain_name == "" ? 0 : 1
  zone_id         = element(data.aws_route53_zone.parent.*.zone_id, 0)
  name            = local.fqdn
  allow_overwrite = true
  type            = "NS"
  ttl             = 300

  records = [
    local.public_ns.0,
    local.public_ns.1,
    local.public_ns.2,
    local.public_ns.3,
  ]
}

resource "aws_acm_certificate" "default" {
  count                     = var.enabled && var.certificate_enabled ? 1 : 0
  depends_on                = [aws_route53_zone.dns_zone]
  tags                      = module.label.tags
  domain_name               = local.fqdn
  subject_alternative_names = local.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  count           = var.enabled && var.certificate_enabled ? 1 : 0
  zone_id         = local.public_zone_id
  name            = lookup(local.domain_validation_options_list[count.index].0, "resource_record_name")
  type            = lookup(local.domain_validation_options_list[count.index].0, "resource_record_type")
  records         = [lookup(local.domain_validation_options_list[count.index].0, "resource_record_value")]
  allow_overwrite = true
  ttl             = 300
}

resource "aws_acm_certificate_validation" "default" {
  count                   = var.enabled && var.certificate_enabled ? 1 : 0
  depends_on              = [aws_route53_record.validation]
  certificate_arn         = join("", aws_acm_certificate.default.*.arn)
  validation_record_fqdns = aws_route53_record.validation.*.fqdn
}
