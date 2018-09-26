# sandbox-aws

To test Kubernetes on AWS:
- create VPC and networking
- create & configure k8s
- send logs to an AWS ESaaS
- monitoring by Prometheus
- IngressController by Traefik
- Custom Metrics

+

app test: "exercice3"

# IaC

## prerequisite

Connect to your aws account:

```
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


## layer-base

go to iac/layer-base

```
terraform apply --yes
```

## layer-kubernetes

go to iac/layer-kubernetes
```
./apply.sh
```


## layer-servicemesh

go to iac/layer-servicemesh
```
./deploy.sh
```

# Test infrastructure

test if custom metrics works: 

kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" | jq .

test if grafana works:

Traefik LoadBalanceur /grafana

ssh ec2-user@BASTION -N -L 9200:ES_HOST:443 -v

go to http://localhost:9200/_plugin/kibana

https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-vpc.html#es-vpc-security

# exercice 3


kubectl get --raw "/apis/exercice3.metrics.k8s.io/v1beta1"

kubectl -n kube-system delete pod --force --grace-period=0 $(kubectl -n kube-system get pods -l app=external-dns | cut -d ' ' -f 1 |  | tail -n +2)
