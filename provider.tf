terraform {
  required_providers {
    aws = {
      version = ">= 5.27"
      source = "hashicorp/aws"
    }
  }
}
terraform {
  backend "s3" {
    bucket                  = "terraform-s3-bucket-resumes"
    key                     = "my-terraform-config"
    region                  = "us-east-1"
    shared_credentials_file = "~/.aws/credentials"
  }
}

provider "aws" {
  access_key = "my_access_key"
  secret_key = "my_secret_key"
  region = "us-east-1"
}

