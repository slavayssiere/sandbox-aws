#!/bin/bash

cd layer-bastion
./apply.sh
cd - 

cd layer-kubernetes
./apply.sh
cd - 

cd layer-services
./apply.sh
cd -
