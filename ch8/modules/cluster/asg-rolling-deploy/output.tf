output "asg_name" {
    value = aws_autoscaling_group.example.name
    description = "The neame of the Auto scaling Group"
}

output "instance_security_group_id"{
    value = aws_security_group.instance.id
    description = "The ID of the security group for the instances in the ASG"
}
