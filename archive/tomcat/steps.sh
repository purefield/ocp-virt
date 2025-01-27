# Setup https://cloud.redhat.com/blog/accessing-your-vm-using-ssh-and-the-web-console
ssh-copy-id jw8p2-user@provision.jw8p2.dynamic.opentlc.com
ssh jw8p2-user@provision.jw8p2.dynamic.opentlc.com
oc login --token=sha256~ETheClNmRi-5gECNjlQ-e3RFAsGkTnxhALTSyj6zkmU --server=https://api.ocp.example.com:6443
oc new-project multi-cloud
oc apply -f ubi9.yaml  --wait=true
oc rsync /srv/openshift/acm/id_rsa* ubi9:/root/.ssh/

# Jump Box Container
oc rsh ubi9
yum install -y openssh-clients
#ssh-keygen -f /root/.ssh/id_rsa -P ''
#cat /root/.ssh/id_rsa.pub

# VM - add platform config map mount, name vm rhel9-vm, label
# enable ssh root login and setup password
# PasswordAuthentication yes
# PermitRootLogin yes
# copy keys from jumpbox to vm
#ssh-copy-id root@rhel9-vm
ssh root@rhel9-vm
sudo su
source ../subscription.txt
subscription-manager register --activationkey $subscriptionKey --org $subscriptionOrg
subscription-manager attach --auto
yum install -y git podman net-tools
git clone https://github.com/purefield/multi-cloud-demo.git
git checkout development
cd multi-cloud-demo/tomcat-demo/demo/
./run.sh
oc label pod virt-launcher-rhel9-ujecwcm2kmcqbee1-whvdn app=helloworld-dev-app


todo: 
add labels to everything
create service 
access app via route
set environment variables
use local registry
cache everything
automate everything
