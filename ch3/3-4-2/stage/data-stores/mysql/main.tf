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

# TODO: VPCからサブネットの情報を持ってくる
resource "aws_db_subnet_group" "example" {
    name = "uekusa-example"
    subnet_ids = [aws_subnet.example.id] # ここにvpcで設定したサブネットを記述
    tags = {
        Name = "uekusa-example"
    }
}

resource "aws_db_instance" "example" {
    identifier = "uekusa-terraform-up-and-running"
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    skip_final_snapshot = true
    db_name = "example_database"
    multi_az = false
    username = var.db_username
    password = var.db_password
}