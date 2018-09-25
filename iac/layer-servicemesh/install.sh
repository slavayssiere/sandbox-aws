
# https://raw.githubusercontent.com/kubernetes/kops/master/addons/prometheus-operator/v0.19.0.yaml

cd manifests
kubectl apply -f .
kubectl apply -f v0.19.0.yaml
cd ..

cd traefik
kubectl apply -f .
cd ..

cd monitoring
kubectl apply -f .
cd ..

kubectl apply -f cm-adapter-serving-certs.yaml -n monitoring

cd custom-metric
kubectl apply -f .
cd ..

helm init --service-account tiller

# # the traefik webui
# htpasswd -bc ./auth traefik password
# kubectl create secret generic traefik-login --from-file auth -n kube-system
# kubectl apply -f traefik-web-ui.yaml

