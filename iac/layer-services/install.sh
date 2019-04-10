#!/bin/bash

test_tiller_present() {
    kubectl get pod -n kube-system -l app=helm,name=tiller | grep Running | wc -l | tr -d ' '
}

until kops validate cluster
do
    echo "Wait for cluster provisionning"
    sleep 10
done

kubectl apply -f helm/rbac.yaml
helm init --service-account tiller # --tiller-tls-verify

test_tiller=$(test_tiller_present)
while [ $test_tiller -lt 1 ]; do
    echo "Wait for Tiller: $test_tiller"
    test_tiller=$(test_tiller_present)
    sleep 1
done

sleep 10

cd cluster-autoscaler
kubectl create ns cluster-autoscaler
helm install --namespace cluster-autoscaler --name aws-autoscaler stable/aws-cluster-autoscaler -f values.yaml
cd ..

cd rook
helm repo add rook-stable https://charts.rook.io/stable
kubectl create ns rook-ceph-system
helm install --namespace rook-ceph-system --name rook-default -f values.yaml rook-stable/rook-ceph
kubectl apply -f cluster.yaml
kubectl apply -f pool.yaml
cd ..

cd prometheus-operator
kubectl create ns monitoring
mkdir tmp && cd tmp
wget https://raw.githubusercontent.com/coreos/prometheus-operator/master/contrib/kube-prometheus/manifests/0prometheus-operator-0prometheusCustomResourceDefinition.yaml
wget https://raw.githubusercontent.com/coreos/prometheus-operator/master/contrib/kube-prometheus/manifests/0prometheus-operator-0alertmanagerCustomResourceDefinition.yaml
wget https://raw.githubusercontent.com/coreos/prometheus-operator/master/contrib/kube-prometheus/manifests/0prometheus-operator-0prometheusruleCustomResourceDefinition.yaml
wget https://raw.githubusercontent.com/coreos/prometheus-operator/master/contrib/kube-prometheus/manifests/0prometheus-operator-0servicemonitorCustomResourceDefinition.yaml
kubectl apply -f .
cd - && rm -Rf tmp

helm install --namespace monitoring --name prom-operator -f values.yaml stable/prometheus-operator
kubectl apply -f .
cd ..

cd kube-prometheus
# https://github.com/helm/charts/tree/master/stable/prometheus-operator
kubectl -n monitoring create secret generic alertmanager-alertmanager-k8s --from-file=alertmanager.yaml
kubectl apply -f prometheus-k8s.yaml
kubectl apply -f alertmanager-k8s.yaml
cd ..

cd manifests
kubectl apply -f .
cd ..

cd traefik-consul
kubectl apply -f .
cd ..

cd traefik-admin
kubectl apply -f .
cd ..

cd traefik-app
kubectl apply -f .
cd ..

cd ingress-monitoring
kubectl apply -f .
cd ..

## apps

cd mysql-operator
kubectl create ns mysql-operator
helm repo add presslabs https://presslabs.github.io/charts
helm install --namespace mysql-operator presslabs/mysql-operator --name mysql-operator -f values.yaml --version 0.2.4
cd -