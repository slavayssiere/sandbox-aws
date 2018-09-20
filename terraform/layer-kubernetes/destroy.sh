#!/bin/bash

export KOPS_STATE_STORE=s3://wescale-slavayssiere-kops
export CLOUD=aws
export NAME=test.slavayssiere.wescale

kops delete cluster $NAME --yes