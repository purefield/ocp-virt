export OK='\033[0;32mOK\033[0m'
baseDomain=$(oc get --namespace openshift-ingress-operator ingresscontrollers/default -o jsonpath='{.status.domain}')
cmd="curl -sk https://coordinate.$baseDomain/_cat/nodes"
echo
echo "$cmd"
echo
echo -e "[ $OK ] Coordinate container is part of the VM cluster:" 
$cmd | grep coordinate -B10 -A10 --color=always
