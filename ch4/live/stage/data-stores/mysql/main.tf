provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
      bucket = "uekusa-terraform-up-and-running-state"
      key = "stage/data-stores/mysql/terraform.tfstate"
      region = "ap-northeast-1"

      dynamodb_table = "uekusa-terraform-up-and-running-locks"
      encrypt = true
  }
}

module "mysql" {
    source = "../../../modules/data-stores/mysql"

    vpc_remote_state_bucket = "uekusa-terraform-up-and-running-state"
    vpc_remote_state_key = "stage/vpc/terraform.tfstate"

    db_instance_type = "db.t3.micro"
    env_name = "stage"

    db_username = var.db_username
    db_password = var.db_password
}