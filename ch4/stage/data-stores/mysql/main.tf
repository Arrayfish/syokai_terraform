provider "aws" {
    region = "ap-northeast-1"
}

terraform {
    backend "s3" {
        bucket = "uekusa-terraform-up-and-running-state"
        key = "stage/data-stores/mysql/terraform.tfstate"
        region = "ap-northeast-1"

        dynamodb_table = "uekusa-terraform-up-and-running-locks"
        encrypt = true
    }
}

data "terraform_remote_state" "vpc" {
    backend = "s3"
    config = {
        bucket = "uekusa-terraform-up-and-running-state"
        key = "stage/vpc/terraform.tfstate"
        region = "ap-northeast-1"
    }
}

data "aws_subnets" "example" {
    filter {
        name = "vpc-id"
        values = [data.terraform_remote_state.vpc.outputs.vpc_id]
    }
}

resource "aws_db_subnet_group" "example" {
    name = "uekusa-example"
    subnet_ids = data.aws_subnets.example.ids
    tags = {
        Name = "uekusa-example"
    }
}

resource "aws_db_instance" "example" {
    identifier = "uekusa-terraform-up-and-running"
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t3.micro"
    skip_final_snapshot = true
    db_name = "example_database"
    db_subnet_group_name = aws_db_subnet_group.example.name
    username = var.db_username
    password = var.db_password
}