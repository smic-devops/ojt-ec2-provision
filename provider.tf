#provider.tf
terraform {
  required_version = ">= 1.6"


  required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = ">= 5.0"
   }
  }
}


provider "aws" {
  region     = "ap-southeast-1"
  access_key = "AWS access key"
  secret_key = "AWS secret key"
  token      = "AWS token"
}