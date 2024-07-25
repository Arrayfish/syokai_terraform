output "alb_dns_name"{
    value = module.alb.alb_dns_name
    description = "The domain name of the load balancer"
}

output "asg_name" {
    value = module.asg.asg_name
    description = "The name of the Autoscaling Group"
}

output "alb_security_group_id" {
    value = aws_security_group.alb.id
    description = "The ID of the Security Group attached to the load balancer."
}

output "instance_security_group_id" {
    value = module.asg.instance_security_group_id
    description = "The ID of the EC2 Instance Security Group."
}