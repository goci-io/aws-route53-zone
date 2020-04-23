
variable "stage" {
  type        = string
  description = "The stage the hosted zone will be created for"
}

variable "namespace" {
  type        = string
  description = "Namespace the hosted zone belongs to. Used to determine the root domain if domain_name is not set"
}

variable "attributes" {
  type        = list
  default     = []
  description = "Additional attributes (e.g. `eu1`)"
}

variable "tags" {
  type        = map
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}

variable "name" {
  type        = string
  default     = ""
  description = "Name of the subdomain to create under <stage>.<attributes>.<namespace>.tld if domain_name is not set"
}

variable "parent_domain_name" {
  type        = string
  default     = ""
  description = "Domain name of the parent hosted zone or the root domain zone"
}

variable "is_parent_private_zone" {
  type        = bool
  default     = false
  description = "Whether the parent hosted zone is private or not"
}

variable "tld" {
  type        = string
  default     = "com"
  description = "The top level domain to use if not specified by parent_domain_name or domain_name"
}

variable "domain_name" {
  type        = string
  default     = ""
  description = "Fully qualified domain to create the hosted zone for (if not automatically build from label)"
}

variable "omit_prod_stage" {
  type        = bool
  default     = true
  description = "If true the prod stage will be omitted in the dns zone if it equals one of prod, main or production"
}

variable "aws_assume_role_arn" {
  type        = string
  default     = ""
  description = "Role to assume to get access to AWS"
}

variable "aws_parent_account_assume_role_arn" {
  type        = string
  default     = ""
  description = "Role to assume to get access to the AWS parent Account"
}

variable "certificate_alternative_names" {
  type        = list(string)
  default     = []
  description = "Alternative names to add to the certificate"
}

variable "certificate_enabled" {
  default     = true
  description = "Whether an AWS ACM certificate should be issued for the domain"
}

variable "create_public_zone" {
  type        = bool
  default     = true
  description = "If the new hosted zone is private and you want to validate for example an ACM certificate an additional public zone can be created"
}

variable "zone_vpcs" {
  type        = list(string)
  default     = []
  description = "VPCs assigned to the new hosted zone. Assigning VPC to the zone makes it private."
}

variable "external_zone_vpcs" {
  type        = map(string)
  default     = {}
  description = "Map of VPC IDs and region as value from external AWS accounts to create route53 zone association for"
}

variable "tf_bucket" {
  type        = string
  default     = ""
  description = "The Bucket name to load remote state from"
}

variable "vpc_module_state" {
  type        = string
  default     = ""
  description = "The key or path to the state where a VPC module was installed. It must expose a vpc_id output"
}

variable "enabled" {
  default     = true
  description = "Whether this module should be enabled"
}
