#!/bin/bash

export KOPS_STATE_STORE=s3://wescale-slavayssiere-kops
export CLOUD=aws
export NAME=test.slavayssiere.wescale

jinja2 cluster-template.yaml ../data.yaml --format=yaml > ./cluster.yaml

kops create -f ./cluster.yaml
kops create secret --name $NAME sshpublickey admin -i ~/.ssh/id_rsa.pub
rm ./cluster.yaml

kops update cluster $NAME --yes


AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq .Account | tr -d \")

terraform apply \
    -var "cluster_name=$NAME" \
    -var "account_id=$AWS_ACCOUNT_ID"

