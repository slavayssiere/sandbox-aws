resource "aws_security_group" "kafka_sg" {
  name        = "kafka_sg"
  description = "Allow SSH traffic and get from web"
  vpc_id      = "${data.terraform_remote_state.layer-base.vpc_id}"

  ingress {
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    security_groups = ["${data.terraform_remote_state.layer-bastion.sg_bastion}"]
  }

  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
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

resource "aws_iam_role" "kafka_role" {
  name               = "kafka_role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.bastion-assume-role-policy.json}"
}

resource "aws_iam_role_policy_attachment" "S3-attach" {
  role       = "${aws_iam_role.kafka_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "kafka_profile" {
  name = "kafka_profile"
  role = "${aws_iam_role.kafka_role.name}"
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = "${data.terraform_remote_state.layer-base.vpc_id}"
  tags {
    Name = "demo_sn_private_*"
  }
}

resource "aws_instance" "kafka_cluster" {
  count                       = 3
  ami                         = "ami-0bdb1d6c15a40392c"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.kafka_sg.id}"]
  subnet_id                   = "${element(data.aws_subnet_ids.private_subnets.ids, count.index)}"
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.kafka_profile.name}"
  key_name                    = "slavayssiere-sandbox-wescale"

  tags {
    Name = "${format("Kafka-%02d", count.index)}"
  }
}
