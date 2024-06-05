provider "aws" {
    region = "ap-northeast-1"
}

module "webserver_cluster" {
    source = "../../../modules/services/webserver-cluster"

    cluster_name = "webservers-prod"
    db_remote_state_bucket = "uekusa-terraform-up-and-running-state"
    db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"

    instance_type = "t2.small"
    min_size = 5
    max_size = 10
}