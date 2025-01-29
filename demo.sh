. ./format/format.sh
NAMESPACE=$1
__ "OpneShift Virtualization Demo" 1
__ "Configuration" 2

__ "Namespace" 3
_? "What namespace should we use?" NAMESPACE ocp-virt $NAMESPACE

__ "Base Domain" 3
BASEDOMAIN=$(oc get --namespace openshift-ingress-operator ingresscontrollers/default -o jsonpath='{.status.domain}')
_? "What base domain should we use?" BASEDOMAIN "" $BASEDOMAIN

__ "Red Hat Subscription" 3
if [ -s subscription.txt ]; then . subscription.txt; fi
_? "Key" SUBSCRIPTION_KEY key $SUBSCRIPTION_KEY
_? "ORG" SUBSCRIPTION_ORG org $SUBSCRIPTION_ORG

__ "Create resources" 2
export SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"

__ "Create namespace" 3
cmd "oc new-project $NAMESPACE"

__ "Create common resources" 3
cmd oc apply -f installation.template.yaml -n openshift
cmd 'oc process ocp-virt-demo-setup-template -n openshift -p NAMESPACE='$NAMESPACE' -p BASEDOMAIN="'$BASEDOMAIN'" -p SUBSCRIPTION_ORG=$SUBSCRIPTION_ORG -p SUBSCRIPTION_KEY=$SUBSCRIPTION_KEY -p SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" | oc apply -f -'

__ "Create virtual machines" 3
cmd oc apply -f application.template.yaml -n openshift
for name in es-master00 es-master01 es-master02; do
  __ "$name" 4
  cmd 'oc process ocp-virt-demo-vms-template -n openshift -p VMNAME='$name' -p NAMESPACE='$NAMESPACE' -p BASEDOMAIN="'$BASEDOMAIN'" -p SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" | oc apply -f -'
done

__ "Run demo:" 2
__ "Wait for virtual machines" 3
oo 4 "oc get vmi -n $NAMESPACE --no-headers=true | wc -l"

__ "Wait for elasticsearch" 3
jsonpath="{range .items[*]}{@.metadata.name}{': '}{@.status.conditions[?(@.type=='Ready')].status}{'\n'}"
oo 3 'oc get pods -n '$NAMESPACE' -l app=elasticsearch,elasticsearch=master -o jsonpath="'$jsonpath'" | grep True | wc -l'

__ "Confirm elasticsearch cluster is healthy" 3
cmd ./elasticsearch/demo.sh
___ "Are the 3 VMs and Coordinate Container up?"

__ "Apply elasticsearch index pattern" 3
cmd ./elasticsearch/kibana.data-view.sh

__ "What did we create?" 2
cmd oc get all -l demo=ocp-virt -n $NAMESPACE

__ "The End" 1
