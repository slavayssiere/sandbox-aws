
# https://raw.githubusercontent.com/kubernetes/kops/master/addons/prometheus-operator/v0.19.0.yaml

until kops validate cluster
do
    echo "Wait for cluster provisionning"
    sleep 10
done

kubectl annotate ns kube-system iam.amazonaws.com/permitted=".*"

cd rook
kubectl apply -f operator.yaml
kubectl apply -f cluster.yaml
kubectl apply -f pool.yaml
cd ..

cd prometheus-operator
kubectl apply -f namespace-monitoring.yaml
kubectl apply -f prometheus-operator.yaml
kubectl apply -f .
cd ..

cd kube-prometheus
kubectl -n monitoring create secret generic alertmanager-main --from-file=alertmanager.yaml
kubectl apply -f .
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

cd monitoring
kubectl apply -f .
cd ..

kubectl apply -f cm-adapter-serving-certs.yaml -n monitoring

cd custom-metric
kubectl apply -f .
cd ..

# cd kiam
# kubectl create secret generic kiam-server-tls -n kube-system \
#   --from-file=ca.pem \
#   --from-file=server.pem \
#   --from-file=server-key.pem

# kubectl create secret generic kiam-agent-tls -n kube-system \
#   --from-file=ca.pem \
#   --from-file=agent.pem \
#   --from-file=agent-key.pem

# kubectl apply -f .
# cd ..

helm init --service-account tiller

# helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com
# helm repo add aws-sb https://awsservicebroker.s3.amazonaws.com/charts

# helm install svc-cat/catalog \
#     --name catalog \
#     --namespace catalog

# helm install aws-sb/aws-servicebroker \
#     --name aws-servicebroker \
#     --namespace aws-sb \
#     --version 1.0.0-beta.2 \
#     -f ./service-broker/values.yaml

# helm install incubator/jaeger \
#     --name myrel \
#     --set provisionDataStore.cassandra=false \
#     --set provisionDataStore.elasticsearch=false \
#     --set storage.type=elasticsearch \
#     --set storage.elasticsearch.host=$ES_HOST \
#     --set storage.elasticsearch.port=443

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

