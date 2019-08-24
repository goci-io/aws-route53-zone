terraform {
  required_version = ">= 0.12.1"
  backend "s3" {}
}

provider "aws" {
  version = "~> 2.25"
  alias   = "parent-zone-account"
  
  assume_role {
    role_arn = var.aws_parent_account_assume_role_arn
  }
}

provider "aws" {
  version = "~> 2.25"
  
  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}
