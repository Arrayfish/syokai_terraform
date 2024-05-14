provider "aws" {
    region = "ap-northeast-1"
}

resource "aws_instance" "example" {
    ami = "ami-0b5c74e235ed808b9"
    instance_type = "t2.micro"
    tags={
        Name = "uekusa-terraform-example"
    }
}