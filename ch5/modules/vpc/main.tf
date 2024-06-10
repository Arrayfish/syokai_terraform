resource "aws_vpc" "example" {
    cidr_block = var.vpc_cidr_block
    tags ={
        Name = "uekusa-${var.env_name}-example-vpc"
    }   
}

# DB用の複数AZのサブネットを作成
resource "aws_subnet" "db_subnet1" {
    vpc_id = aws_vpc.example.id
    cidr_block = var.subnet1_cidr_block
    availability_zone = "ap-northeast-1a"
    tags = {
        Name = "uekusa-${var.env_name}-example-subnet1"
    }
}
resource "aws_subnet" "db_subnet2" {
    vpc_id = aws_vpc.example.id
    cidr_block = var.subnet2_cidr_block
    availability_zone = "ap-northeast-1c"
    tags = {
        Name = "uekusa-${var.env_name}-example-subnet2"
    }
}

# webサーバのためのインターネットゲートウェイを作成
resource "aws_internet_gateway" "example" {
    vpc_id = aws_vpc.example.id
    tags = {
        Name = "uekusa-${var.env_name}-example-igw"
    }
}

# ルートテーブルを作成
resource "aws_route_table" "example"{
    vpc_id = aws_vpc.example.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.example.id
    }
}

## ルートテーブルとサブネットを関連付け
resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.db_subnet1.id
    route_table_id = aws_route_table.example.id
}
resource "aws_route_table_association" "b" {
    subnet_id = aws_subnet.db_subnet2.id
    route_table_id = aws_route_table.example.id
}