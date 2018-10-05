#!/bin/bash

cd terraform
terraform apply
cd ..

cd ../layer-bastion
bastion_hostname=$(terraform output bastion_public_dns)
cd ../layer-kafka

scp install-bastion.sh ec2-user@$bastion_hostname:~
ssh ec2-user@$bastion_hostname:~ "./install-bastion.sh"