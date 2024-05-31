provider "aws" {
    region = "ap-northeast-1"
}
terraform {
  backend "s3" {
        bucket = "uekusa-terraform-up-and-running-state"
        key = "stage/vpc/terraform.tfstate"
        region = "ap-northeast-1"

        dynamodb_table = "uekusa-terraform-up-and-running-locks"
        encrypt = true
    }
}

resource "aws_vpc" "example" {
    cidr_block = "10.2.0.0/16"
    tags ={
        Name = "uekusa-example-vpc"
    }   
}

# DB用の複数AZのサブネットを作成
resource "aws_subnet" "db_subnet1" {
    vpc_id = aws_vpc.example.id
    cidr_block = "10.2.1.0/24"
    availability_zone = "ap-northeast-1a"
    tags = {
        Name = "uekusa-example-subnet1"
    }
}
resource "aws_subnet" "db_subnet2" {
    vpc_id = aws_vpc.example.id
    cidr_block = "10.2.2.0/24"
    availability_zone = "ap-northeast-1c"
    tags = {
        Name = "uekusa-example-subnet2"
    }
}
