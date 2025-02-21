. ./format/format.sh
NAMESPACE=$1
VMS=$2
CUSTOMER=${3:-Our Valued Customer}
__ "OpneShift Virtualization Demo" 1
__ "Configuration" 2

__ "Namespace" 3
_? "What namespace should we use?" NAMESPACE ocp-virt $NAMESPACE

__ "Number VMs" 3
_? "How many Elasticsearch VMs should we use?" vms 3 $VMS

__ "Base Domain" 3
BASEDOMAIN=$(oc get --namespace openshift-ingress-operator ingresscontrollers/default -o jsonpath='{.status.domain}')
_? "What base domain should we use?" BASEDOMAIN "" $BASEDOMAIN

__ "Red Hat Subscription" 3
if [ -s subscription.txt ]; then . subscription.txt; fi
_? "Key" SUBSCRIPTION_KEY key $SUBSCRIPTION_KEY
_? "ORG" SUBSCRIPTION_ORG org $SUBSCRIPTION_ORG

__ "Create resources" 2
if [ ! -s ./ssh.id_rsa ]; then 
__ "Create ssh keys" 3
cmd 'ssh-keygen -m PEM -N ""  -f ./ssh.id_rsa'
fi
export SSH_PUBLIC_KEY="$(cat ssh.id_rsa.pub)"
export SSH_PRIVATE_KEY="$(cat ssh.id_rsa)"

if [[ "$(oc get project $NAMESPACE -o=jsonpath='{.metadata.name}' 2>/dev/null)" != $NAMESPACE ]]; then
__ "Create namespace" 3
cmd "oc new-project $NAMESPACE --display-name='$CUSTOMER'"
fi

__ "Create common resources" 3
if [[ "$(oc get secrets/wildcard-cert -n $NAMESPACE -o name 2>/dev/null)" != 'secret/wildcard-cert' ]]; then 
__ "For demo purpose re-use the ingress cert" 4
item="secret/letsencrypt-prod-private-key -n openshift-ingress"
cmd "oc get $item -o yaml | sed 's/namespace: openshift-ingress/namespace: $NAMESPACE/' | sed 's/name: .*/name: wildcard-cert/' | oc apply -f -"
fi

__ "Import setup template into cluster" 4
cmd oc apply -f setup.template.yaml -n openshift
__ "Process parameters and apply" 4
cmd 'oc process ocp-virt-demo-setup-template -n openshift -p NAMESPACE='$NAMESPACE' -p BASEDOMAIN="'$BASEDOMAIN'" -p SUBSCRIPTION_ORG=$SUBSCRIPTION_ORG -p SUBSCRIPTION_KEY=$SUBSCRIPTION_KEY -p SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" -p SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" -p SHARDS=$vms | oc apply -f -'
___ "We use our imported setup template to instantiate our environment" 10

__ "Create virtual machines" 3
__ "Import vm template into cluster" 4
cmd oc apply -f vm.template.yaml -n openshift
for i in $(seq 0 $((vms -1))); do
name=$(printf "es-master%02d" "$i")
__ "Process parameters for $name and apply" 4
cmd 'oc process ocp-virt-demo-vms-template -n openshift -p VMNAME='$name' -p NAMESPACE='$NAMESPACE' -p BASEDOMAIN="'$BASEDOMAIN'" -p SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" | oc apply -f -'
done
___ "We created $vms VMs using our vm template" 10

__ "Run demo:" 2
__ "Wait for virtual machines" 3
oo $((vms + 1)) "oc get vmi -n $NAMESPACE --no-headers=true --ignore-not-found=true | wc -l"

__ "Wait for elasticsearch vms to be ready" 3
jsonpath="{range .items[*]}{@.status.conditions[?(@.type=='Ready')].status}{'\n'}"
oo $vms 'oc get pods -n '$NAMESPACE' -l app=elasticsearch,elasticsearch=master -o jsonpath="'$jsonpath'" | grep True | wc -l'

__ "Wait for elasticsearch cluster to be ready" 3
oo $vms "./elasticsearch/demo.sh | grep es-master | wc -l"

__ "Confirm elasticsearch cluster is healthy" 3
cmd ./elasticsearch/demo.sh
___ "Did $vms VMs and Coordinate Container form an Elasticsearch cluster?" 10

__ "Check elasticsearch on es-master vms via RHEL container" 3
for i in $(seq 0 $((vms -1))); do
  name=$(printf "es-master%02d" "$i")
  cmd 'oc rsh -n '$NAMESPACE' pod/ubi9 ssh -o StrictHostKeyChecking=accept-new elasticsearch@'$name' systemctl status elasticsearch | egrep Active -B2 --color=always'
done
___ "Are all Elasticsearch services healthy?" 10

__ "Our Cronjob setup Elasticseach Index and Kibana View" 3
cmd oc logs -n aardvark -l job-name=elasticsearch-init-job --since=30m

__ "What did we create?" 2
kinds=$(grep '\- kind' *.template.yaml -h | sort -n | uniq | sed 's/ //g' | cut -d':' -f 2 | paste -sd "," - )
kindsMatch=$(echo $kinds | sed 's/,/|/g' )
names='es-master|elasticsearch|data-generator|coordinate|kibana|windows2019|cockpit'
oc get $kinds -l demo=ocp-virt -n $NAMESPACE | \
   egrep --color=always -i "^($kindsMatch)" -B10 -A10 | \
   GREP_COLOR='01;36' egrep --color=always $names -B10 -A10

__ "Have fun storming the castle!" 1
_? "Open demo urls in Chrome?" openChrome yes
if [[ "$openChrome" == "yes" ]]; then
    /opt/google/chrome/chrome --new-window \
        --profile-directory=Default \
        https://es-master00.apps.virt.ola.purefield.nl/system/services#/elasticsearch.service?name=elastic \
        https://data-generator.apps.virt.ola.purefield.nl \
        https://kibana.apps.virt.ola.purefield.nl/app/discover\#/ \
        https://github.com/purefield/ocp-virt/commit/23a92611a631008ff5fe77a122f63ed34f3a8d79 \
        https://console-openshift-console.apps.virt.ola.purefield.nl/catalog/ns/default?category=other\&catalogType=Template \
        https://grafana-open-cluster-management-observability.apps.acm.ola.purefield.nl/d/WfJLo3rSz/executive-dashboards-single-cluster-view?orgId=1
fi
