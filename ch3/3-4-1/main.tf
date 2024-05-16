terraform {
  backend "s3" {
    key = "workspace-example/terraform.tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "example" {
    ami = "ami-07c589821f2b353aa"
    instance_type = terraform.workspace == "default" ? "t2.medium" : "t2.micro"
}

