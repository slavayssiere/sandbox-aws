# sandbox-aws

This project is my AWS sandbox.

I'm using it to test Kubernetes on AWS.

Some layers folders in "IaC" are used to create:

- create VPC and networking
- create & configure k8s
- send logs to an AWS ESaaS
- monitoring by Prometheus
- IngressController by Traefik
- Custom Metrics

Another folder "namespace" are used to create some configurated namespace and get one kubeconfig file for CI/CD usage.

And the other one is an app test: "exercice3". It's just an webservice. See "app test" below.

## IaC

### Prerequisite

Connect to your aws account:

```language-bash
#!/usr/bin/env bash
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_STS AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SECURITY_TOKEN AWS_SESSION_TOKEN
export USERNAME=terraform
export AWS_DEFAULT_REGION=eu-west-1
export AWS_ACCESS_KEY_ID=***
export AWS_SECRET_ACCESS_KEY=***
export ROLE_NAME=EC2TerraformRole
export ACCOUNT_ARN=arn:aws:iam::***
export MFA_CODE=$1
AWS_STS=($(aws sts assume-role --role-arn $ACCOUNT_ARN:role/$ROLE_NAME --serial-number $ACCOUNT_ARN:mfa/$USERNAME --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken,Credentials.Expiration]' --output text --token-code $MFA_CODE --role-session-name $ROLE_NAME))
export AWS_ACCESS_KEY_ID=${AWS_STS[0]}
export AWS_SECRET_ACCESS_KEY=${AWS_STS[1]}
export AWS_SECURITY_TOKEN=${AWS_STS[2]}
export AWS_SESSION_TOKEN=${AWS_STS[2]}
```

To use this project you have to install these software:

- jinja2-cli
- jq
- terraform
- kops

You have to create:

- a S3 bucket for Terraform tfstates
- a S3 bucket for Kops states
- a S3 bucket for your private Helm chart

## Launch projects

### layer-base

go to iac/layer-base

the first time:

```language-bash
terraform init -backend-config="bucket=$BUCKET_TFSTATES"
```

for next apply:

```language-bash
terraform apply \
    -var "account_id=$ACCOUNT_ID" \
    -var "region=eu-west-1" \
    -var "private_dns_zone=$PRIVATE_DNS_ZONE"
```

## layer-bastion

```language-bash
cd ../layer-bastion/
./apply.sh
```

### layer-kubernetes

go to iac/layer-kubernetes

the first time:

```language-bash
terraform init -backend-config="bucket=$BUCKET_TFSTATES"
```

for next apply:

```language-bash
./apply.sh
```

### layer-servicemesh

go to iac/layer-servicemesh

```language-bash
./deploy.sh
```

## Test infrastructure

connect to your bastion:

```language-bash
cd iac/layer-kubernetes/
bastion_dns=$(terraform output bastion_public_dns)
ssh ec2-user@bastion_dns
```

test if custom metrics works:

```language-bash
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" | jq .
```

```language-bash
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa
ssh -A ec2-user@bastion.aws-wescale.slavayssiere.fr \
    -L 8080:admin-tools.slavayssiere.wescale:8080 \
    -L 8081:admin-tools.slavayssiere.wescale:80 \
    -L 6443:api.test.slavayssiere.wescale:443
```

## exercice 3

### deploy

exercice3/kubernetes/*

### test

### delete pod

kubectl -n monitoring delete pod --force --grace-period=0 $(kubectl -n monitoring get pods -l k8s-app=fluentd-es | cut -d ' ' -f 1 | tail -n +2)

### alertmanager

To test alertmanager you can use this [example](https://gist.github.com/cherti/61ec48deaaab7d288c9fcf17e700853a)

## TODO

- [backbox](https://medium.com/the-telegraph-engineering/how-prometheus-and-the-blackbox-exporter-makes-monitoring-microservice-endpoints-easy-and-free-of-a986078912ee)
- opentracing
  - Jaeger
  - activer dans Traefik
  - ajouter dans exercice3
