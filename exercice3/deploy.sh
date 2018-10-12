#!/bin/bash

cd ../iac/layer-bastion
bastion_hostname=$(terraform output bastion_public_dns)
cd -

scp -r -oStrictHostKeyChecking=no kubernetes ec2-user@$bastion_hostname:/tmp

scp -oStrictHostKeyChecking=no ../namespace/kubeconfigs/exercice3-cicd.kubeconfig ec2-user@$bastion_hostname:/tmp/exercice3-cicd.kubeconfig

ssh -oStrictHostKeyChecking=no ec2-user@$bastion_hostname "KUBECONFIG=/tmp/exercice3-cicd.kubeconfig kubectl apply -f /tmp/kubernetes"


