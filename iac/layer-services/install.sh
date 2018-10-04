
# https://raw.githubusercontent.com/kubernetes/kops/master/addons/prometheus-operator/v0.19.0.yaml

until kops validate cluster
do
    echo "Wait for cluster provisionning"
    sleep 1
done

cd manifests
kubectl apply -f v0.19.0.yaml
kubectl -n monitoring create secret generic alertmanager-main --from-file=alertmanager.yaml
kubectl apply -f .
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


# curl -XPOST $ES_HOST/api/saved_objects/index-pattern -H "Content-Type: application/json" -H "kbn-xsrf: true" -d @kibana/default-index-pattern.json

# curl -XPOST -H 'Content-Type: application/json' \
#   "$ES_HOST/.kibana/index-pattern/applogs-*" \
#   -d'{"title":"applogs-*","timeFieldName":"@timestamp","notExpandable":true}'

# curl -XDELETE -H 'Content-Type: application/json' \
#   "$ES_HOST/.kibana/index-pattern/applogs-*"

# curl -f -XPOST -H 'Content-Type: application/json' \
#     -H 'kbn-xsrf: anything' \
#     "$ES_HOST/api/saved_objects/index-pattern/applogs-*" \
#     -d'{"attributes":{"title":"applogs-*","timeFieldName":"@timestamp"}}'

# curl -XPOST "$ES_HOST/api/saved_objects/index-pattern/applogs-*" -H "Content-Type: application/json" -H "kbn-xsrf: true" -d @kibana/default-index-pattern.json

# curl "$ES_HOST/api/saved_objects/index-pattern/applogs-*" -H "Content-Type: application/json" -H "kbn-xsrf: true"

# # the traefik webui
# htpasswd -bc ./auth traefik password
# kubectl create secret generic traefik-login --from-file auth -n kube-system
# kubectl apply -f traefik-web-ui.yaml

