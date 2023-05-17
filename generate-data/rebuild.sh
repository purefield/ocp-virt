host=$(oc get route -l app=elasticsearch -l role=api -A -o jsonpath='{.items[].status.ingress[].host}')
podman kill generate-data
podman build -t generate-data .
podman run -it --rm -p 3000:3000 -e ES_NODE=$host:443 -e DATA_RATE=1 -e DATA_SIZE=5 -e DATA_BATCH=10 --name generate-data generate-data:latest
