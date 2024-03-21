curl -kX POST "https://$(oc get route -l app=kibana -A -ojsonpath='{.items[0].spec.host}')/api/data_views/data_view" -H "kbn-xsrf: true" -H "Content-Type: application/json" -d '
{
  "data_view": {
    "name":"demo",
    "title": "generated*",
    "timeFieldName": "timestamp"
  }
}'

