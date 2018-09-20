#!/bin/bash

export KOPS_STATE_STORE=s3://wescale-slavayssiere-kops
export CLOUD=aws
export NAME=test.slavayssiere.wescale

terraform destroy

kops delete cluster $NAME --yes