#!/bin/bash

export NAME="exercice3"

mkdir tmp

jinja2 namespace.yaml > ./tmp/namespace.yaml
jinja2 prometheus.yaml > ./tmp/prometheus.yaml
jinja2 rbac-cicd.yaml > ./tmp/rbac-cicd.yaml


cd ../iac/layer-bastion
bastion_hostname=$(terraform output bastion_public_dns)
cd -

scp -r -oStrictHostKeyChecking=no tmp ec2-user@$bastion_hostname:~
scp -oStrictHostKeyChecking=no ./kube-config-creator.sh ec2-user@$bastion_hostname:~/tmp

ssh -oStrictHostKeyChecking=no ec2-user@$bastion_hostname "kubectl apply -f ./tmp/"
ssh -oStrictHostKeyChecking=no ec2-user@$bastion_hostname "./tmp/kube-config-creator.sh $NAME"

scp -oStrictHostKeyChecking=no ec2-user@$bastion_hostname:~/k8s-cicd-conf kubeconfigs/$NAME-cicd.kubeconfig
ssh -oStrictHostKeyChecking=no ec2-user@$bastion_hostname "rm -Rf ./tmp && rm k8s-cicd-conf"

rm -Rf tmp

