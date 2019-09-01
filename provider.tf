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

  dynamic "assume_role" {
    iterator = role
    for_each = var.aws_parent_account_assume_role_arn == "" ? [] : [var.aws_parent_account_assume_role_arn]

    content {
      role_arn = role.value
    }
  }
}

provider "aws" {
  alias = "member_account"

  dynamic "assume_role" {
    iterator = role
    for_each = var.aws_assume_role_arn == "" ? [] : [var.aws_assume_role_arn]

    content {
      role_arn = role.value
    }
  }
}
