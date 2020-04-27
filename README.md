# aws-route53-zone

#### Maintained by [@goci-io/prp-terraform](https://github.com/orgs/goci-io/teams/prp-terraform)

![Terraform Validate](https://github.com/goci-io/aws-route53-zone/workflows/Terraform%20Validate/badge.svg?branch=master&event=push)

This terraform module provisions a new AWS Route53 Hosted Zone. 

If you need to delegate DNS from a different AWS Account or use a parent hosted zone the Nameservers are automatically synchronized by using the specified `aws_parent_account_assume_role_arn` to assume an external role defined in the AWS profile. The member account access can be specified using `aws_assume_role_arn` variable.

The `domain_name` can either be specified in the `terraform.tfvars` or autogenerated from a label module. 
When autogenerating the name the following convention is applied: `<name>.<stage>.<attributes>.<namespace>.tld`. 
The `tld` will be sourced either from `parent_domain_zone` if set or the `tld` variable itself. 
For the following stages the stage will be omitted when using the autogenerated label (`prod`, `production`, `main`)

### Usage

```hcl
module "zone" {
  source              = "git::https://github.com/goci-io/aws-route53-zone.git?ref=tags/<latest-version>"
  namespace           = "goci"
  stage               = "staging"
  attributes          = ["eu1"]
  parent_domain_name  = "goci.io"
}
```
_This example will result in a hosted zone with the name staging.eu1.goci.io with an additional NS entry in the parent zone_

Look into the [terraform.tfvars](terraform.tfvars.example) to see more examples.

### Configuration

| Name | Description | Default |
|-----------------|----------------------------------------|---------|
| namespace | The company or organization prefix (eg: goci) | - |
| stage | The stage this configuration is for (eg: staging or prod) | - |
| name | Optional name (subdomain) for this hosted zone | "" |
| attributes | Additional attributes (e.g. `["eu1"]`) | `[]` | 
| tags | Additional tags (e.g. `map("BusinessUnit", "XYZ")` | `{}` | 
| delimiter | Delimiter between namespace, stage, name and attributes | `-` |
| domain_name | Overwrite auto generated domain name | "" |
| tld | The top level domain to use if not already specified via `domain_name` or `parent_domain_name` | - |
| parent_domain_name | The parent hosted zone to sync Nameservers with | "" |
| is_parent_private_zone | Whether the parent hosted zone is private | false |
| certificate_enabled | Whether to create an AWS ACM certificate | true |
| certificate_alternative_names | Additional domains to include in the certificate. Includes always *.<domain> | `[]` |
| omit_prod_stage | Whether the prod stage should be omitted from the zone name (when stage is prod, production or main) | true |
| create_public_zone | If the new hosted zone is private and you want to validate for example an ACM certificate an additional public zone can be created | true |
| zone_vpcs | VPC IDs to attach to the hosted zone. This makes the hosted zone private. | `[]` |
| tf_bucket | The bucket name to read the remote state from (required if vpc_module_state is used) | "" |
| vpc_module_state | The key to the state file of an vpc module. Must expose `vpc_id` output | "" |
| aws_assume_role_arn | A role to assume to create the hosted zone and certificate in | "" |
| aws_parent_account_assume_role_arn | A role to assume to create the NS record in the parent zone | "" |
