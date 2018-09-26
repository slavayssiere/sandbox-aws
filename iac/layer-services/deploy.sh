#!/bin/bash

cd ../layer-kubernetes
bastion_hostname=$(terraform output bastion_public_dns)
cd ../layer-servicemesh

cd ../layer-base
export ES_HOST=$(terraform output es_host)
cd ../layer-servicemesh

# ./gencerts.sh

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq .Account | tr -d \")

jinja2 ./templates/kube2iam.yaml > ./manifests/kube2iam.yaml
jinja2 ./templates/fluentd-to-es.yaml > ./manifests/fluentd-to-es.yaml

scp -r -oStrictHostKeyChecking=no ./manifests ec2-user@$bastion_hostname:~
scp -r -oStrictHostKeyChecking=no ./traefik ec2-user@$bastion_hostname:~
scp -r -oStrictHostKeyChecking=no ./monitoring ec2-user@$bastion_hostname:~
scp -r -oStrictHostKeyChecking=no ./custom-metric ec2-user@$bastion_hostname:~
scp -oStrictHostKeyChecking=no cm-adapter-serving-certs.yaml ec2-user@$bastion_hostname:~/cm-adapter-serving-certs.yaml

scp -oStrictHostKeyChecking=no ./install.sh ec2-user@$bastion_hostname:~/install.sh

ssh -oStrictHostKeyChecking=no ec2-user@$bastion_hostname ~/install.sh


rm ./manifests/kube2iam.yaml
rm ./manifests/fluentd-to-es.yaml