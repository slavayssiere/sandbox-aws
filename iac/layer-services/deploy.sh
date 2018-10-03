#!/bin/bash

cd ../layer-kubernetes
bastion_hostname=$(terraform output bastion_public_dns)
cd ../layer-services

cd ../layer-base
export ES_HOST=$(terraform output es_host)
cd ../layer-services

./gencerts.sh

export ACCOUNT_ID=$(aws sts get-caller-identity | jq .Account | tr -d \")

jinja2 ./templates/kube2iam.yaml > ./manifests/kube2iam.yaml
jinja2 ./templates/fluentd-to-es.yaml > ./manifests/fluentd-to-es.yaml
jinja2 ./templates/alert-manager-sns-forwarder.yaml > ./manifests/alert-manager-sns-forwarder.yaml

scp -r -oStrictHostKeyChecking=no . ec2-user@$bastion_hostname:~
ssh -oStrictHostKeyChecking=no ec2-user@$bastion_hostname "./install.sh"


rm ./manifests/kube2iam.yaml
rm ./manifests/fluentd-to-es.yaml