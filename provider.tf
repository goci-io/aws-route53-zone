terraform {
  required_version = ">= 0.12.1"

  required_providers {
    aws   = "~> 2.25"
    null  = "~> 2.1"
    local = "~> 1.3"
  }
}

provider "aws" {
  alias = "parent_account"

  assume_role {
    role_arn = var.aws_parent_account_assume_role_arn
  }
}

provider "aws" {
  alias = "member_account"

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}
