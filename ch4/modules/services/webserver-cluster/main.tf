locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}

resource "aws_lb" "example" {
  name               = "uekusa-${var.cluster_name}-lb-example"
  load_balancer_type = "application"
  subnets = tolist(data.aws_subnets.main.ids)
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port = local.http_port
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
    name = "uekusa-${var.cluster_name}-asg"
    port = var.server_port
    protocol = "HTTP"
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

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
    name = "uekusa-${var.cluster_name}-alb"
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
    # allow inbound http requests
    ingress {
        from_port = local.http_port
        to_port = local.http_port
        protocol = local.tcp_protocol
        cidr_blocks = local.all_ips
    }

    # allow all outbound request
    egress {
        from_port = local.any_port
        to_port = local.any_port
        protocol = local.any_protocol
        cidr_blocks = local.all_ips
    }
}

data "terraform_remote_state" "db" {
    backend = "s3"
    config = {
        bucket = var.db_remote_state_bucket
        key = var.db_remote_state_key
        region = "ap-northeast-1"
    }
}

resource "aws_launch_template" "example" {
  image_id               = "ami-07c589821f2b353aa"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = base64encode(
    templatefile("user-data.sh", {
      server_port = var.server_port
      db_address = data.terraform_remote_state.db.outputs.address
      db_port = data.terraform_remote_state.db.outputs.port
    })
  )
  # Autoscaling Groupがある起動設定を使用する場合に必要
  lifecycle {
    create_before_destroy = true
  }
}

data "terraform_remote_state" "vpc" {
    backend = "s3"
    config = {
        bucket = var.db_remote_state_bucket
        key = var.db_remote_state_key
        region = "ap-northeast-1"
    }
}

data "aws_subnets" "main" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.vpc.outputs.vpc_id]
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

  min_size = var.min_size
  max_size = var.max_size

  tag {
    key                 = "Name"
    value               = "uekusa-${var.cluster_name}-asg-example"
    propagate_at_launch = true
  }
}


resource "aws_security_group" "instance" {
  name   = "uekusa-&{var.cluster_name}-alb"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
}
