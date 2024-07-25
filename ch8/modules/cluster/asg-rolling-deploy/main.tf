locals {
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}

resource "aws_launch_template" "example" {
  image_id               = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = var.user_data
  # Autoscaling Groupがある起動設定を使用する場合に必要
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  name = var.cluster_name
  launch_template {
    id      = aws_launch_template.example.id
    version = aws_launch_template.example.latest_version
  }
  vpc_zone_identifier = var.subnet_ids
  target_group_arns = var.target_group_arns
  health_check_type = var.health_check_type

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

resource "aws_security_group" "instance" {
  name   = "uekusa-${var.cluster_name}-alb"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "allow_8080_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instance.id

  from_port   = var.server_port
  to_port     = var.server_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}
