
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

variable "aws_profile" {
  type        = string
  default     = ""
  description = "The AWS profile to use to get access to the Route53 hosted zone owner account"
}
