export host=$(oc get route -l app=elasticsearch -l role=coordinate -A -o jsonpath='{.items[].status.ingress[].host}')
echo "Connect to: $host"
./mappings.curl $host
./sample-data.curl $host
