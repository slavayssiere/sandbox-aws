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

wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod +x jq-linux64
sudo mv jq-linux64 /usr/local/bin/jq


echo "export KOPS_STATE_STORE={{ environ('KOPS_STATE_STORE') }}" >> /home/ec2-user/.bashrc
echo "export ES_HOST=https://{{ environ('ES_HOST') }}" >> /home/ec2-user/.bashrc
echo "kops export kubecfg {{ environ('NAME') }} >> /dev/null 2>&1" >> /home/ec2-user/.bashrc
echo "export NAME={{ environ('NAME') }} >> /dev/null 2>&1" >> /home/ec2-user/.bashrc

# ansible

sudo amazon-linux-extras install -y ansible2

wget https://raw.github.com/ansible/ansible/devel/contrib/inventory/ec2.py
wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo mv ec2.py /etc/ansible/
sudo mv ec2.ini /etc/ansible/

sudo chmod a+x /etc/ansible/ec2.py

python get-pip.py --user
pip install boto --user
rm get-pip.py

sudo sed -i.bak "s/destination_variable = public_dns_name/destination_variable = private_dns_name/g" /etc/ansible/ec2.ini
sudo sed -i.bak "s/vpc_destination_variable = ip_address/vpc_destination_variable = private_ip_address/g" /etc/ansible/ec2.ini
sudo sed -i.bak "s/#elasticache = False/elasticache = False/g" /etc/ansible/ec2.ini
sudo sed -i.bak "s/#rds = False/rds = False/g" /etc/ansible/ec2.ini
