#!/bin/bash

curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops

wget -O kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

wget -O helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-rc.4-linux-amd64.tar.gz
tar -xf helm.tar.gz
chmod +x linux-amd64/helm
sudo mv linux-amd64/helm /usr/local/bin/helm


echo "export KOPS_STATE_STORE=s3://wescale-slavayssiere-kops" >> /home/ec2-user/.bashrc
echo "kops export kubecfg test.slavayssiere.wescale >> /dev/null 2>&1" >> /home/ec2-user/.bashrc

