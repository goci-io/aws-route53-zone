terraform {
  required_version = ">= 0.12.1"

  required_providers {
    aws   = "~> 2.25"
    null  = "~> 2.1"
    local = "~> 1.3"
  }
}

provider "aws" {
  alias = "owner"
}

provider "aws" { 
}
