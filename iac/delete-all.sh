#!/bin/bash

cd layer-bastion/

./destroy.sh 

cd -

cd layer-kubernetes/

./destroy.sh &

cd -
