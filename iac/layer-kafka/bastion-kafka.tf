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

  # allow https for client installation
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_iam_policy_document" "bastion-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bastion_role" {
  name               = "bastion_role"
  path               = "/system/"
  assume_role_policy = "${data.aws_iam_policy_document.bastion-assume-role-policy.json}"
}

resource "aws_iam_role_policy_attachment" "S3-attach" {
  role       = "${aws_iam_role.bastion_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_instance" "bastion" {
  ami                         = "ami-0bdb1d6c15a40392c"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.allow_ssh.id}"]
  subnet_id                   = "${data.terraform_remote_state.layer-base.sn_public_a_id}"
  associate_public_ip_address = true
  user_data                   = "${file("install-bastion.sh")}"
  iam_instance_profile        = "${aws_iam_instance_profile.bastion_profile.name}"
  key_name                    = "slavayssiere-sandbox-wescale"

  tags {
    Name = "Bastion-${var.cluster_name}"
  }
}

output "bastion_public_dns" {
  value = "${aws_instance.bastion.public_dns}"
}
