. ./format/format.sh
__ "Create htpasswd secret" 4
cmd "oc create secret generic htpasswd -n openshift-config --from-literal htpasswd='daniel:$apr1$wX6yA8lQ$jTj5rr3n6pNQg3vuee9qQ.'"

__ "Create htpasswd provider" 4
patch='[{"op":"add","path":"/spec/identityProviders/-","value":{"htpasswd":{"fileData":{"name":"htpasswd"}},"mappingMethod":"claim","name":"htpasswd","type":"HTPasswd"}}]'
cmd "oc patch oauth cluster --type='json' -p='$patch'"
