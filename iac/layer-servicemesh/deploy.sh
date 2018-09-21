#!/bin/bash

cd ../layer-kubernetes
bastion_hostname=$(terraform output bastion_public_dns)
cd ../layer-servicemesh

./gencerts.sh

scp -r -oStrictHostKeyChecking=no ./manifests ec2-user@$bastion_hostname:~
scp -r -oStrictHostKeyChecking=no ./traefik ec2-user@$bastion_hostname:~
scp -r -oStrictHostKeyChecking=no ./monitoring ec2-user@$bastion_hostname:~
scp -r -oStrictHostKeyChecking=no ./custom-metric ec2-user@$bastion_hostname:~
scp -oStrictHostKeyChecking=no cm-adapter-serving-certs.yaml ec2-user@$bastion_hostname:~/cm-adapter-serving-certs.yaml

ssh -oStrictHostKeyChecking=no ec2-user@$bastion_hostname 

# https://raw.githubusercontent.com/kubernetes/kops/master/addons/prometheus-operator/v0.19.0.yaml

cd manifests
kubectl apply -f .
kubectl apply -f v0.19.0.yaml
cd ..

cd traefik
kubectl apply -f .
cd ..

cd monitoring
kubectl apply -f .
cd ..

kubectl create -f cm-adapter-serving-certs.yaml -n monitoring

cd custom-metric
kubectl apply -f .
cd ..

helm init --service-account tiller

