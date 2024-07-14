terraform {
  required_providers {
    aws = {
      version = "value"
      source = "hashicorp/aws"
    }
  }
}


provider "aws" {
  access_key = "my_access_key"
  secret_key = "my_secret_key"
  region = "us-east-1"
}