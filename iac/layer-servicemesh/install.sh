
# the traefik webui
htpasswd -bc ./auth traefik password
kubectl create secret generic traefik-login --from-file auth -n kube-system
kubectl apply -f traefik-web-ui.yaml

