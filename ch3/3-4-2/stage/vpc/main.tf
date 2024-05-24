terraform {
  backend "s3" {
        bucket = "uekusa-terraform-up-and-running-state"
        key = "stage/vpc/terraform.tfstate"
        region = "ap-northeast-1"

        dynamodb_table = "uekusa-terraform-up-and-running-locks"
        encrypt = true
    }
}

provider "aws" {
    region = "ap-northeast-1"
}

resource "aws_vpc" "example" {
    cidr_block = "10.2.0.0/16"
    tags ={
        Name = "uekusa-example-vpc"
    }   
}
# DB用の複数AZにまたがるサブネットを作成
resource "aws_subnet" "db_subnet" {
    vpc_id = aws_vpc.example.id
    cidr_block = "10.2.0.1/24"
    availability_zone = "ap-northeast-1a"
    tags = {
        Name = "uekusa-example-subnet"
    }
}
