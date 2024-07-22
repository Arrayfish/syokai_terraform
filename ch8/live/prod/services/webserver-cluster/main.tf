provider "aws" {
    region = "ap-northeast-1"
}

terraform {
    backend "s3" {
        bucket = "uekusa-terraform-up-and-running-state"
        key = "prod/services/webserver-cluster/terraform.tfstate"
        region = "ap-northeast-1"

        dynamodb_table = "uekusa-terraform-up-and-running-locks"
        encrypt = true
    }
}

module "webserver_cluster" {
    source = "../../../../modules/services/webserver-cluster"

    cluster_name = "webservers-prod"
    db_remote_state_bucket = "uekusa-terraform-up-and-running-state"
    db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"

    vpc_remote_state_bucket = "uekusa-terraform-up-and-running-state"
    vpc_remote_state_key = "prod/vpc/terraform.tfstate"

    instance_type = "t2.small"
    min_size = 5
    max_size = 10
    enable_autoscaling = true

    custom_tags = {
        Owner = "team-foo"
        DeployedBy = "terraform"
    }
}