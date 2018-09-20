provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "wescale-slavayssiere-terraform"
    region = "eu-west-1"
    key    = "kubernetes/layer-kubernetes"
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

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH traffic"
  vpc_id      = "${data.terraform_remote_state.layer-base.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = "ami-0bdb1d6c15a40392c"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.allow_ssh.id}"]
  subnet_id                   = "${data.terraform_remote_state.layer-base.sn_public_a_id}"
  associate_public_ip_address = true
  user_data                   = "${file("install-bastion.sh")}"
}
