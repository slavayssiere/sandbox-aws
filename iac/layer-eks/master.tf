resource "aws_security_group" "demo-cluster" {
  name        = "terraform-eks-demo-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${data.terraform_remote_state.layer-base.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "terraform-eks-demo"
  }
}

resource "aws_security_group_rule" "demo-cluster-ingress-workstation-https" {
  source_security_group_id = "${data.terraform_remote_state.layer-bastion.sg_bastion}"
  description              = "Allow workstation to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.demo-cluster.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_eks_cluster" "demo" {
  name     = "${var.cluster-name}"
  role_arn = "${aws_iam_role.demo-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.demo-cluster.id}"]
    subnet_ids         = ["${data.terraform_remote_state.layer-base.sn_private_a_id}", "${data.terraform_remote_state.layer-base.sn_private_b_id}", "${data.terraform_remote_state.layer-base.sn_private_c_id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.demo-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.demo-cluster-AmazonEKSServicePolicy",
  ]
}

resource "aws_security_group_rule" "demo-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.demo-cluster.id}"
  source_security_group_id = "${aws_security_group.demo-node.id}"
  to_port                  = 443
  type                     = "ingress"
}
