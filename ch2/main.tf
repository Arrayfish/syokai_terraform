provider "aws" {
    region = "ap-northeast-1"
}

# resource "aws_instance" "example" {
#     ami = "ami-07c589821f2b353aa"
#     instance_type = "t2.micro"
#     subnet_id = aws_subnet.main.id
#     vpc_security_group_ids = [aws_security_group.instance.id]
#     user_data = <<-EOF
#     #!/bin/bash
#     echo "Hello, World!!!!!!!!" > index.html
#     nohup busybox httpd -f -p ${var.server_port} & 
#     EOF

#     user_data_replace_on_change = true

#     tags={
#         Name = "uekusa-terraform-example"
#     }
# }
resource "aws_launch_configuration" "example" {
    image_id = "ami-07c589821f2b353aa"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instance.id]
    user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World!!!!!!!!" > index.html
    nohup busybox httpd -f -p ${var.server_port} & 
    EOF

    # Autoscaling Groupがある起動設定を使用する場合に必要
    lifecycle {
        create_before_destroy = true
    }
}

data "aws_vpc" "main" {
    filter{
        name = "tag:Name"
        values = ["uekusa-example-vpc"]
    }
}
data "aws_subnets" "main" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.main.id]
    }
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.name
    vpc_zone_identifier = data.aws_subnets.main.ids

    min_size = 2
    max_size = 10

    tag{
        key = "Name"
        value = "uekusa-terraform-asg-example"
        propagate_at_launch = true
    }
}


resource "aws_security_group" "instance" {
    name = "uekusa-example-instance"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

variable "server_port"{
    description = "The port the server will use for HTTP requests"
    type = number
    default = 8080
}

# output "public_ip"{
#     value = aws_instance.example.public_ip
#     description = "The public IP address of the web server"
# }

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "uekusa-example-vpc"
  }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "default" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
}
resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-northeast-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "uekusa-example-subnet"
    }
}

resource "aws_route_table_association" "default" {
    subnet_id      = aws_subnet.main.id
    route_table_id = aws_route_table.default.id
}

