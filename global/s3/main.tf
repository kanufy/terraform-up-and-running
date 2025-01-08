provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "knfy-terraform-up-and-running-state"

  # 誤ってS3バケットを削除するのを防止
  lifecycle {
    prevent_destroy = true
  }
}

# ステートファイルの完全な履歴が見られるように、バージョニングを有効化
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# デフォルトでサーバサイド暗号化を有効化
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 明示的にこのS3バケットに対する全パブリックアクセスをブロック
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# terraform {
#   backend "s3" {
#     # バケット名は自分のものに置き換えること
#     bucket         = "knfy-terraform-up-and-running-state"
#     key            = "global/s3/terraform.tfstate"
#     region         = "us-east-1"
#     # DynamoDBテーブル名は自分のものに置き換えること
#     dynamodb_table = "terraform-up-and-running-locks"
#     encrypt        = true
#   }
# }


# この設定だけでは足りない。バケットやリージョンなどの他の設定は、
# terraform initコマンドへの-backend-config引数で渡される。
terraform {
  backend "s3" {
    key = "example/terraform.tfstate"
  }
}
