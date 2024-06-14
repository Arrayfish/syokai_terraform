variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
  type = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type = string
}

variable "vpc_remote_state_bucket" {
  description = "The name of the S3 bucket for the vpc's remote state"
  type = string
}

variable "vpc_remote_state_key" {
  description = "The path for the vpc's remote state in S3"
  type = string
}

variable "instance_type" {
  description = "The type of EC2 instances to run (e.g. t2.micro)"
  type = string
}

variable "min_size" {
  description = "The minimum number of instances in the autoscaling group"
  type = number
}

variable "max_size" {
  description = "The maximum number of instances in the autoscaling group"
  type = number
}

variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type = map(string)
  default = {}
}