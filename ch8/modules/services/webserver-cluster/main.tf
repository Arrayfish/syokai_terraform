locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}

resource "aws_lb" "example" {
  name               = "uekusa-${var.cluster_name}-lb"
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
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port = local.http_port
  to_port = local.http_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_http_outbound" {
  type = "egress"
  security_group_id = aws_security_group.alb.id

  from_port = local.any_port
  to_port = local.any_port
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
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
  image_id               = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = base64encode(
    templatefile("${path.module}/user-data.sh", {
      server_port = var.server_port
      db_address = data.terraform_remote_state.db.outputs.address
      db_port = data.terraform_remote_state.db.outputs.port
      server_text = var.server_text
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
        bucket = var.vpc_remote_state_bucket
        key = var.vpc_remote_state_key
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
  name = var.cluster_name
  launch_template {
    id      = aws_launch_template.example.id
    version = aws_launch_template.example.latest_version
  }
  vpc_zone_identifier = data.aws_subnets.main.ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  instance_refresh{
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
  tag {
    key                 = "Name"
    value               = "uekusa-${var.cluster_name}-asg-example"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = {
      for key, value in var.custom_tags:
      key => upper(value)
      if key != "Name"
    }

    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
}


resource "aws_security_group" "instance" {
  name   = "uekusa-&{var.cluster_name}-alb"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
}

resource "aws_security_group_rule" "allow_8080_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instance.id

  from_port   = var.server_port
  to_port     = var.server_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
    count = var.enable_autoscaling ? 1 : 0
    
    scheduled_action_name = "scale-out-during-business-hours"
    min_size = 2
    max_size = 10
    desired_capacity = 10
    recurrence = "0 9 * * *"

    autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
    count = var.enable_autoscaling ? 1 : 0

    scheduled_action_name = "scale-in-at-night"
    min_size= 2
    max_size = 10
    desired_capacity = 2
    recurrence = "0 17 * * *"

    autoscaling_group_name = aws_autoscaling_group.example.name
}
