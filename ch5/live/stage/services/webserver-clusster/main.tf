provider "aws" {
    region = "ap-northeast-1"
}

terraform {
    backend "s3" {
        bucket = "uekusa-terraform-up-and-running-state"
        key = "stage/services/webserver-cluster/terraform.tfstate"
        region = "ap-northeast-1"

        dynamodb_table = "uekusa-terraform-up-and-running-locks"
        encrypt = true
    }
}

module "webserver_cluster" {
    source = "../../../../modules/services/webserver-cluster"

    ami = "ami-07c589821f2b353aa"
    server_text = "New server text!"

    cluster_name = "webservers-stage"
    db_remote_state_bucket = "uekusa-terraform-up-and-running-state"
    db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"

    vpc_remote_state_bucket = "uekusa-terraform-up-and-running-state"
    vpc_remote_state_key = "stage/vpc/terraform.tfstate"

    instance_type = "t2.micro"
    min_size = 2
    max_size = 10
    enable_autoscaling = false
}