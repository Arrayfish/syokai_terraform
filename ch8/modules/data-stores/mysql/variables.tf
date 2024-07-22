variable "db_username"{
    description = "The username for the database"
    type = string
    sensitive = true
}

variable "db_password"{
    description = "The password for the database"
    type = string
    sensitive = true
}

variable "env_name" {
    description = "The name of the environment"
    type = string
}

variable "vpc_remote_state_bucket"{
    description = "The name of the S3 bucket for the vpc's remote state"
    type = string
}

variable "vpc_remote_state_key" {
  description = "The path for the vpc's remote state in S3"
  type = string
}

variable "db_instance_type" {
  description = "The type of RDS instance to run (e.g. db.t3.micro)"
  type = string
}