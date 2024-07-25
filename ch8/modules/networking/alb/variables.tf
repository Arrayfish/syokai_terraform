variable "alb_name" {
    description = "The name to use for this ALB"
    type = string
}

variable "subnet_ids"{
    description = "The subnet IDs to deploy the ALB to"
    type = list(string)
}

variable "vpc_id" {
    description = "The ID of the VPC to deploy the ALB to"
    type = string
}