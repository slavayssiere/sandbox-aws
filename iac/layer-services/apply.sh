#!/bin/bash

cd ../layer-bastion
bastion_hostname=$(terraform output bastion_public_dns)
cd ../layer-base
private_dns_zone=$(terraform output private_dns_zone)
export ES_HOST=$(terraform output es_host)
cd ../layer-services

if [[ -z "${NAME_CLUSTER}" ]]; then
  export NAME=test.$private_dns_zone
else
  export NAME=$NAME_CLUSTER.$private_dns_zone
fi

FILE="./cm-adapter-serving-certs.yaml"
if [ ! -e "$FILE" ]; then
   echo "File $FILE does not exist."
   ./gencerts.sh
   rm apiserver-key.pem
   rm apiserver.pem
   rm apiserver.csr
   rm metrics-ca.crt
   rm metrics-ca.key
   rm metrics-ca-config.json
fi

export ACCOUNT_ID=$(aws sts get-caller-identity | jq .Account | tr -d \")

jinja2 ./templates/cluster-autoscaler.yaml > ./manifests/cluster-autoscaler.yaml
jinja2 ./templates/kube2iam.yaml > ./manifests/kube2iam.yaml
jinja2 ./templates/fluentd-to-es.yaml > ./manifests/fluentd-to-es.yaml
jinja2 ./templates/alert-manager-sns-forwarder.yaml > ./manifests/alert-manager-sns-forwarder.yaml

scp -r -oStrictHostKeyChecking=no . ec2-user@$bastion_hostname:~
ssh -oStrictHostKeyChecking=no ec2-user@$bastion_hostname "./install.sh"


rm ./manifests/kube2iam.yaml
rm ./manifests/fluentd-to-es.yaml
rm ./manifests/cluster-autoscaler.yaml
rm ./manifests/alert-manager-sns-forwarder.yaml
