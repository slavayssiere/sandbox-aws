#!/bin/bash


cd ../layer-bastion
bastion_hostname=$(terraform output bastion_public_dns)
cd ../layer-eks

CLUSTER_NAME="test-seb"

# cf: https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html

terraform apply -var "cluster-name=$CLUSTER_NAME"


scp -r -oStrictHostKeyChecking=no config-map-aws-auth.yaml ec2-user@$bastion_hostname:~
scp -r -oStrictHostKeyChecking=no install.sh ec2-user@$bastion_hostname:~

ssh -oStrictHostKeyChecking=no ec2-user@$bastion_hostname "./install.sh"


