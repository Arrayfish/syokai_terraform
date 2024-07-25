output "alb_dns_name" {
    value = aws_lb.example.dns_name
    description = "The DNS name of the ALB"
}

output "alb_http_listener_arn" {
    value = aws_lb_listener.http.arn
    description = "The ARN of the HTTP listener"
}

output "alb_security_group_id" {
    value = aws_security_group_alb.id
    description = "The ID of the security group for the ALB"
}