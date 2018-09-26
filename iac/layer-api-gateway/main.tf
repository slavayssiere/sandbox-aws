provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "wescale-slavayssiere-terraform"
    region = "eu-west-1"
    key    = "kubernetes/layer-api-gateway"
  }
}

data "terraform_remote_state" "layer-base" {
  backend = "s3"
  config {
    bucket = "wescale-slavayssiere-terraform"
    region = "eu-west-1"
    key    = "kubernetes/layer-base"
  }
}

variable "region" {
  default = "eu-west-1"
}

variable "account_id" {
  default = "549637939820"
}
