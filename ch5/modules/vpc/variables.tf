variable "env_name" {
    description = "The name of the environment"
    type = string
}

variable "vpc_cidr_block" {
    description = "The CIDR block for the VPC"
    type = string
}

variable "subnet1_cidr_block" {
    description = "The CIDR block for the first subnet"
    type = string
}

variable "subnet2_cidr_block" {
    description = "The CIDR block for the second subnet"
    type = string
}