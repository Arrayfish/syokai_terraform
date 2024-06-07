data "terraform_remote_state" "vpc" {
    backend = "s3"
    config = {
        bucket = var.vpc_remote_state_bucket
        key = var.vpc_remote_state_key
        region = "ap-northeast-1"
    }
}

data "aws_subnets" "example" {
    filter {
        name = "vpc-id"
        values = [data.terraform_remote_state.vpc.outputs.vpc_id]
    }
}

resource "aws_db_subnet_group" "example" {
    name = "uekusa-${var.env_name}-db-subnet-group"
    subnet_ids = data.aws_subnets.example.ids
    tags = {
        Name = "uekusa-example"
    }
}

resource "aws_db_instance" "example" {
    identifier = "uekusa-${var.env_name}-example-db"
    engine = "mysql"
    allocated_storage = 10
    instance_class = var.db_instance_type
    skip_final_snapshot = true
    db_name = "uekusa_${var.env_name}_example_database" # including hyphen in the db name is not allowed
    db_subnet_group_name = aws_db_subnet_group.example.name
    username = var.db_username
    password = var.db_password
}