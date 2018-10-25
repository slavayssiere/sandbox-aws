#!/bin/bash

cd ../iac/layer-bastion
bastion_hostname=$(terraform output bastion_public_dns)
cd -


helm package --version 0.0.2 ./exercice3 
helm s3 push ./exercice3-0.0.1.tgz my-charts

# scp -oStrictHostKeyChecking=no ../namespace/kubeconfigs/exercice3-cicd.kubeconfig ec2-user@$bastion_hostname:/tmp/exercice3-cicd.kubeconfig

# ssh -oStrictHostKeyChecking=no ec2-user@$bastion_hostname "KUBECONFIG=/tmp/exercice3-cicd.kubeconfig kubectl apply -f /tmp/kubernetes"

ssh -oStrictHostKeyChecking=no ec2-user@$bastion_hostname "helm repo update"
ssh -oStrictHostKeyChecking=no ec2-user@$bastion_hostname "helm --tiller-namespace exercice4 install --name test --namespace exercice3 --version 0.0.1 my-charts/exercice3"

KUBECONFIG=../namespace/kubeconfigs/exercice3-cicd.kubeconfig kubectl get pods

helm install --name test --namespace exercice3 --version 0.0.1 my-charts/exercice3
helm install --name test my-charts/exercice3 -f values.yaml --version 0.0.5
