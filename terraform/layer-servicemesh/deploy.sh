#!/bin/bash

cd ../layer-kubernetes
bastion_hostname=$(terraform output bastion_public_dns)
cd ../layer-servicemesh

scp -r -oStrictHostKeyChecking=no ./manifests ec2-user@$bastion_hostname:~
scp -r -oStrictHostKeyChecking=no ./traefik ec2-user@$bastion_hostname:~
scp -r -oStrictHostKeyChecking=no ./monitoring ec2-user@$bastion_hostname:~

ssh -oStrictHostKeyChecking=no ec2-user@$bastion_hostname 

# https://raw.githubusercontent.com/kubernetes/kops/master/addons/prometheus-operator/v0.19.0.yaml

cd manifests
kubectl create -f .
kubectl apply -f v0.19.0.yaml
cd ..

cd traefik
kubectl create -f .
cd ..

cd monitoring
kubectl create -f .
cd ..

helm init --service-account tiller

