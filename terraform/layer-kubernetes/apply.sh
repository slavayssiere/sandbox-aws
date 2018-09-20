#!/bin/bash

export KOPS_STATE_STORE=s3://wescale-slavayssiere-kops
export CLOUD=aws
export NAME=test.slavayssiere.wescale

terraform apply

jinja2 cluster-template.yaml ../data.yaml --format=yaml > ./cluster.yaml

kops create -f ./cluster.yaml
kops create secret --name test.slavayssiere.wescale sshpublickey admin -i ~/.ssh/id_rsa.pub
rm ./cluster.yaml

kops update cluster test.slavayssiere.wescale --yes
