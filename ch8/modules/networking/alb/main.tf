locals {
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
  http_port = 80
}
resource "aws_lb" "example" {
  name               = "uekusa-${var.alb_name}-lb"
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

resource "aws_security_group" "alb" {
    name = "uekusa-${var.alb_name}-alb"
    vpc_id = var.vpc_id
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

