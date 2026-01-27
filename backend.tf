terraform {
  backend "s3" {
    bucket         = "infrawave-terraform-state-1769531403"
    key            = "infrawave/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "infrawave-terraform-lock"
  }
}
