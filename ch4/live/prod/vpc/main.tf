provider "aws" {
    region = "ap-northeast-1"
}

terraform {
    backend "s3" {
        bucket = "uekusa-terraform-up-and-running-state"
        key = "prod/vpc/terraform.tfstate"
        region = "ap-northeast-1"

        dynamodb_table = "uekusa-terraform-up-and-running-locks"
        encrypt = true
    }
}

module "vpc" {
    source = "../../modules/vpc"

    env_name = "prod"

    vpc_cidr_block = "10.2.0.0/16"

    subnet1_cidr_block = "10.2.1.0/24"
    subnet2_cidr_block = "10.2.2.0/24"
}