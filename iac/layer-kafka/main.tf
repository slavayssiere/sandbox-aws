provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "wescale-slavayssiere-terraform"
    region = "eu-west-1"
    key    = "kubernetes/layer-kafka"
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

data "terraform_remote_state" "layer-bastion" {
  backend = "s3"

  config {
    bucket = "wescale-slavayssiere-terraform"
    region = "eu-west-1"
    key    = "kubernetes/layer-bastion"
  }
}
