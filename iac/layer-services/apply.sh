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

if [[ -z "${PUBLIC_DNS_ZONE}" ]]; then
  export PUBLIC_DNS_ZONE="aws-wescale.slavayssiere.fr"
fi

if [[ -z "${PRIVATE_DNS_ZONE}" ]]; then
  export PRIVATE_DNS_ZONE="slavayssiere.wescale"
fi

export ACCOUNT_ID=$(aws sts get-caller-identity | jq .Account | tr -d \")

mkdir manifests

jinja2 ./templates/kube2iam.yaml > ./manifests/kube2iam.yaml
jinja2 ./templates/fluentd-to-es.yaml > ./manifests/fluentd-to-es.yaml
jinja2 ./templates/route53-externalDNS.yaml > ./manifests/route53-externalDNS.yaml
jinja2 ./templates/traefik-svc-private.yaml > ./traefik-admin/traefik-svc.yaml
jinja2 ./templates/traefik-svc-public.yaml > ./traefik-app/traefik-svc.yaml


scp -r -oStrictHostKeyChecking=no . ec2-user@$bastion_hostname:~
ssh -oStrictHostKeyChecking=no ec2-user@$bastion_hostname "./install.sh"

rm -Rf ./manifests
rm ./traefik-admin/traefik-svc.yaml
rm ./traefik-app/traefik-svc.yaml
