#!/bin/bash

until test -f /var/lib/cloud/instance/boot-finished
do
    echo "Wait for user data script"
    sleep 1
done


CLUSTER_NAME="test-seb-2"

role_name=$(aws sts get-caller-identity | jq .Arn | tr -d '"')

aws eks update-kubeconfig --name $CLUSTER_NAME --region eu-west-1 --role-arn $role_name
kubectl apply -f config-map-aws-auth.yaml