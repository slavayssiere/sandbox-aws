#!/bin/bash

cd ../layer-base
private_dns_zone=$(terraform output private_dns_zone)
export ES_HOST=$(terraform output es_host)
cd ../layer-kubernetes


if [[ -z "${BUCKET_TFSTATES}" ]]; then
  export BUCKET_TFSTATES="wescale-slavayssiere-terraform"
fi

if [[ -z "${KOPS_STATE_STORE}" ]]; then
  export KOPS_STATE_STORE=s3://wescale-slavayssiere-kops
fi

if [[ -z "${NAME_CLUSTER}" ]]; then
  export NAME=test.$private_dns_zone
else
  export NAME=$NAME_CLUSTER.$private_dns_zone
fi

export CLOUD=aws

jinja2 cluster-template.yaml ../data.yaml --format=yaml > ./cluster.yaml
jinja2 install-bastion-template.sh > install-bastion.sh

kops create -f ./cluster.yaml
kops create secret --name $NAME sshpublickey admin -i ~/.ssh/id_rsa.pub
rm ./cluster.yaml

kops update cluster $NAME --yes

AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq .Account | tr -d \")

terraform apply \
    -var "cluster_name=$NAME" \
    -var "account_id=$AWS_ACCOUNT_ID"

rm ./install-bastion.sh

