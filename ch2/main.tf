provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_lb" "example" {
  name               = "uekusa-lb-example"
  load_balancer_type = "application"
  subnets = tolist(data.aws_subnets.main.ids)
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port = 80
    protocol = "HTTP"
    # デフォルトではシンプルな404ページを返す
    default_action {
        type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "404: page not found"
            status_code = "404"
        }
    }
}

resource "aws_lb_target_group" "asg"{
    name = "uekusa-asg-example"
    port = var.server_port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.main.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_listener_rule" "asg" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100

    condition{
        path_pattern{
            values = ["*"]
        }
    }
    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
    }
}

resource "aws_security_group" "alb" {
    name = "uekusa-example-alb"
    vpc_id = aws_vpc.main.id
    # allow inbound http requests
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # allow all outbound request
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_launch_template" "example" {
  image_id               = "ami-07c589821f2b353aa"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "Hello, World!!!!!!!!" > index.html
    nohup busybox httpd -f -p ${var.server_port} & 
    EOF
  )
  # Autoscaling Groupがある起動設定を使用する場合に必要
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["uekusa-example-vpc"]
  }
}
data "aws_subnets" "main" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

resource "aws_autoscaling_group" "example" {
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
  vpc_zone_identifier = data.aws_subnets.main.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "uekusa-terraform-asg-example"
    propagate_at_launch = true
  }
}


resource "aws_security_group" "instance" {
  name   = "uekusa-example-instance"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

output "alb_dns_name"{
    value = aws_lb.example.dns_name
    description = "The domain name of the load balancer"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "uekusa-example-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  tags = {
    Name = "uekusa-example-subnet"
  }
}

resource "aws_subnet" "sub" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"
  tags = {
    Name = "uekusa-example-subnet2"
  }
}
