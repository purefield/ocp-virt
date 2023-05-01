namespace=$1
lastNamespace=$(cat namespace.last)
lastNamespace=${lastNamespace:-next-gen-virt}
printf -v sshPubKey "%q" $(<../demo.id_rsa.pub tr -d '\n' | base64 -w0)
if [ "x$namespace" == "x" ]
then
   read -p "What namespace name [$lastNamespace]? " namespace
fi
if [ -z "$namespace" ]
then
   namespace="$lastNamespace"
fi
echo "$namespace" > namespace.last
source ../subscription.txt
baseDomain=$(oc get --namespace openshift-ingress-operator ingresscontrollers/default -o jsonpath='{.status.domain}')
if [ -n "$GUID" ]
then
  altDomain=$baseDomain
  baseDomain="apps.$GUID.dynamic.opentlc.com"
  oc create secret tls letsencrypt \
    --cert=~/demo/demo.redhat.com/cert.pem \
    --key=~/demo/demo.redhat.com/privkey.pem \
  -n $namespace --dry-run=client -o yaml >> $namespace.yaml
  echo "---" >> $namespace.yaml
fi
cat namespace.yaml.template | perl -pe "s/\{\{ namespace \}\}/$namespace/g" > $namespace.yaml
echo "---" >> $namespace.yaml
oc create secret generic id-rsa --from-file ../demo.id_rsa -n $namespace --dry-run=client -o yaml >> $namespace.yaml
cat elasticsearch.install.yaml.template kibana.yaml.template coordinate.yaml.template ubi9.yaml.template | \
  perl -pe "s/\{\{ namespace \}\}/$namespace/g" | \
  perl -pe "s/\{\{ baseDomain \}\}/$baseDomain/g" | \
  perl -pe "s/\{\{ subscriptionOrg \}\}/$subscriptionOrg/g" | \
  perl -pe "s/\{\{ subscriptionKey \}\}/$subscriptionKey/g" | \
  perl -MMIME::Base64 -pe "s/\{\{ sshPubKey \}\}/decode_base64('$sshPubKey')/ge" \
  >> $namespace.yaml
for name in es-master00 es-master01 es-master02; do
  cat elasticsearch.master.vm.yaml.template | \
      perl -pe "s/\{\{ name \}\}/$name/g" | \
      perl -pe "s/\{\{ namespace \}\}/$namespace/g" | \
      perl -pe "s/\{\{ baseDomain \}\}/$baseDomain/g" | \
      perl -MMIME::Base64 -pe "s/\{\{ sshPubKey \}\}/decode_base64('$sshPubKey')/ge" \
  >> $namespace.yaml
done
echo "# Apply yaml using:"
echo "oc apply -f $namespace.yaml"
