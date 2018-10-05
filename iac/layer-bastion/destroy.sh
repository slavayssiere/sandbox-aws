#!/bin/bash

if [[ -z "${BUCKET_TFSTATES}" ]]; then
  export BUCKET_TFSTATES="wescale-slavayssiere-terraform"
fi

touch install-bastion.sh
terraform apply \
    -var "bucket_layer_base=$BUCKET_TFSTATES"
rm install-bastion.sh
