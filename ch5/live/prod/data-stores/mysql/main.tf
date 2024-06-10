provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
      bucket = "uekusa-terraform-up-and-running-state"
      key = "prod/data-stores/mysql/terraform.tfstate"
      region = "ap-northeast-1"

      dynamodb_table = "uekusa-terraform-up-and-running-locks"
      encrypt = true
  }
}

module "mysql" {
    source = "github.com/brikis98/terraform-up-and-running-code//code/terraform/04-terraform-module/module-example/modules/services/webserver-cluster?ref=v0.0.2"

    vpc_remote_state_bucket = "uekusa-terraform-up-and-running-state"
    vpc_remote_state_key = "prod/vpc/terraform.tfstate"

    db_instance_type = "db.t3.micro"
    env_name = "prod"

    db_username = var.db_username
    db_password = var.db_password
}