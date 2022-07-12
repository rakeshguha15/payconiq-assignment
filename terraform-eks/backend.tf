terraform {
  backend "s3" {
    bucket  = "terraform-store-payconiq-sample"
    key     = "eks-sample"
    region  = "eu-central-1"
    encrypt = true
  }
}