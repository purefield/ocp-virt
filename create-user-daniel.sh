. ./format/format.sh
__ "Create htpasswd secret" 4
cmd "oc create secret generic htpasswd -n openshift-config --from-literal htpasswd='daniel:$2y$05$GQlPEZ03BPQ4ZzkPD4dhKeM54VjDPN9YtyORDRVT6w.kU1p4Y4ZZ.'"

__ "Create htpasswd provider" 4
patch='[{"op":"add","path":"/spec/identityProviders/-","value":{"htpasswd":{"fileData":{"name":"htpasswd"}},"mappingMethod":"claim","name":"htpasswd","type":"HTPasswd"}}]'
cmd "oc patch oauth cluster --type='json' -p='$patch'"
