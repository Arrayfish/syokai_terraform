provider "aws" {
    region = "ap-northeast-1"
}


resource "aws_s3_bucket" "terraform_state" {
    bucket = "uekusa-terraform-up-and-running-state"

    lifecycle {
        prevent_destroy = true
    }
}

# ステートファイルの完全な履歴を閲覧可能にするために、バケットのバージョニングを有効にする
resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
        status = "Enabled"
    }
}

#　サーバサイド暗号化を有効にする
resource "aws_s3_bucket_server_side_encryption_configuration" "default"{
    bucket = aws_s3_bucket.terraform_state.id

    rule{
        apply_server_side_encryption_by_default{
            sse_algorithm = "AES256"
        }
    }
}

# 誤って公開しないようにするためのパブリックアクセスのブロック
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.terraform_state.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

# 分散ロックのためのdynamoDBテーブル
resource "aws_dynamodb_table" "terraform_locks" {
    name = "uekusa-terraform-up-and-running-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}

terraform {
  backend "s3" {
    bucket = "uekusa-terraform-up-and-running-state"
    key = "global/s3/terraform.tfstate"
    region = "ap-northeast-1"
    dynamodb_table = "uekusa-terraform-up-and-running-locks"
    encrypt = true
  }
}

output "s3_bucket_arn" {
    value = aws_s3_bucket.terraform_state.arn
    description = "The ARN of the S3 bucket"
}
output "dynamodb_table_name" {
    value = aws_dynamodb_table.terraform_locks.name
    description = "The name of the DynamoDB table"
}