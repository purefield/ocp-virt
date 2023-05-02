export OK='\033[0;32mOK\033[0m'
export ERROR='\033[0;31mERROR\033[0m'
host=$(oc get route -l app=elasticsearch -l role=api -A -o jsonpath='{.items[].status.ingress[].host}')
cmd="curl -sk https://$host/_cat/nodes"
echo
echo "$cmd"
echo
out=$($cmd 2>&1)
if [[ $? -eq 0 && "x$(echo "$out" | grep es-master)" != "x" ]]; then
  if [ "x$(echo "$out" | grep coordinate)" == "x" ]; then
    echo -e "[ $ERROR ] VM cluster is up. Waiting on container" 
    echo "$out" 
  else
    echo -e "[ $OK    ] Coordinate container is part of the VM cluster:" 
    echo "$out" | grep coordinate -B10 -A10 --color=always
  fi
else
  printf "[ $ERROR ] Not ready yet.\n"
fi
echo
