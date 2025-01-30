. ./format/format.sh
NAMESPACE=$1
VMS=$2
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

__ "Create namespace" 3
cmd "oc new-project $NAMESPACE"

__ "Create common resources" 3
cmd oc apply -f installation.template.yaml -n openshift
cmd 'oc process ocp-virt-demo-setup-template -n openshift -p NAMESPACE='$NAMESPACE' -p BASEDOMAIN="'$BASEDOMAIN'" -p SUBSCRIPTION_ORG=$SUBSCRIPTION_ORG -p SUBSCRIPTION_KEY=$SUBSCRIPTION_KEY -p SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" -p SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" -p SHARDS=$vms | oc apply -f -'

if [[ "$(oc get secrets/wildcard-cert -n $NAMESPACE -o name 2>/dev/null)" != 'secret/wildcard-cert' ]]; then 
 __ "For demo purpose re-use the ingress cert" 3
 item="secret/letsencrypt-prod-private-key -n openshift-ingress"
 cmd "oc get $item -o yaml | sed 's/namespace: openshift-ingress/namespace: $NAMESPACE/' | sed 's/name: .*/name: wildcard-cert/' | oc apply -f -"
fi

__ "Create virtual machines" 3
cmd oc apply -f application.template.yaml -n openshift
for i in $(seq 0 $((vms -1))); do
  name=$(printf "es-master%02d" "$i")
  __ "$name" 4
  cmd 'oc process ocp-virt-demo-vms-template -n openshift -p VMNAME='$name' -p NAMESPACE='$NAMESPACE' -p BASEDOMAIN="'$BASEDOMAIN'" -p SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" | oc apply -f -'
done

__ "Run demo:" 2
__ "Wait for virtual machines" 3
oo $((vms + 1)) "oc get vmi -n $NAMESPACE --no-headers=true | wc -l"

__ "Wait for elasticsearch vms to be ready" 3
jsonpath="{range .items[*]}{@.status.conditions[?(@.type=='Ready')].status}{'\n'}"
oo $vms 'oc get pods -n '$NAMESPACE' -l app=elasticsearch,elasticsearch=master -o jsonpath="'$jsonpath'" | grep True | wc -l'

__ "Wait for elasticsearch cluster to be ready" 3
oo $vms "./elasticsearch/demo.sh | grep es-master | wc -l"

__ "Confirm elasticsearch cluster is healthy" 3
cmd ./elasticsearch/demo.sh
___ "Did $vms VMs and Coordinate Container form an Elasticsearch cluster?"

__ "What did we create?" 2
cmd oc get all -l demo=ocp-virt -n $NAMESPACE

__ "Check elasticsearch on es-master vms via RHEL container" 3
for i in $(seq 0 $((vms -1))); do
  name=$(printf "es-master%02d" "$i")
  cmd 'oc rsh -n copy-cert pod/ubi9 ssh -o StrictHostKeyChecking=accept-new elasticsearch@'$name' systemctl status elasticsearch | egrep Active -B2'
done

__ "Have fun storming the castle!" 1
