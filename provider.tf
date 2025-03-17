#provider.tf
terraform {
  required_version = ">= 1.4"


  required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = ">= 5.0"
   }
  }
}


provider "aws" {
  region     = "ap-southeast-1"
 /* AWS_ACCOUNT = "itss-devops-ojt-jenkins-svc-acct"*/
}