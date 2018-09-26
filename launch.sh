#!/bin/bash

export ACCOUNT_ID="549637939820"
export PRIVATE_DNS_ZONE="slavayssiere.wescale"
export BUCKET_TFSTATES="wescale-slavayssiere-terraform"

export KOPS_STATE_STORE=s3://wescale-slavayssiere-kops
export NAME_CLUSTER=test

# dans layer-base

terraform apply \
    -var "account_id=$ACCOUNT_ID" \
    -var "region=eu-west-1" \
    -var "private_dns_zone=$PRIVATE_DNS_ZONE" \
    -backend-config="bucket=$BUCKET_TFSTATES"


# dans layer-kubernetes

./apply.sh 


