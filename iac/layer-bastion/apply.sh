#!/bin/bash

if [[ -z "${BUCKET_TFSTATES}" ]]; then
  export BUCKET_TFSTATES="wescale-slavayssiere-terraform"
fi

export ACCOUNT_ID=$(aws sts get-caller-identity | jq .Account | tr -d \")

jinja2 install-bastion-template.sh > install-bastion.sh

terraform apply \
    -var "bucket_layer_base=$BUCKET_TFSTATES"
