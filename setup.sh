# sudo dnf install -y git
# git clone https://github.com/purefield/opc-virt.git ~/demo
if [ "x$subscriptionOrg" == "x" ]
then
   read -p "What is your subscription org used to register RHEL? " subscriptionOrg
fi
if [ "x$subscriptionKey" == "x" ]
then
   read -p "What is your subscription key? " subscriptionKey
fi
sudo dnf install -y python3-certbot-apache
ssh-keygen -N ""  -f ~/demo/demo.id_rsa
echo "export subscriptionOrg=$subscriptionOrg
export subscriptionKey=$subscriptionKey" > ~/demo/subscription.txt
perl -pe "s/\{\{ guid \}\}/$GUID/g" ~/demo/demo.redhat.com/letsencrypt.conf.template | sudo tee /etc/httpd/conf.d/letsencrypt.conf > /dev/null
sudo perl -pe "s/443/8443/" -i /etc/httpd/conf.d/ssl.conf
sudo systemctl reload httpd
sudo letsencrypt certonly --apache --agree-tos --email email@example.com \
  -d elasticsearch.apps.$GUID.dynamic.opentlc.com \
  -d coordinate.apps.$GUID.dynamic.opentlc.com \
  -d kibana.apps.$GUID.dynamic.opentlc.com \
  -d es-master00.apps.$GUID.dynamic.opentlc.com \
  -d es-master01.apps.$GUID.dynamic.opentlc.com \
  -d es-master02.apps.$GUID.dynamic.opentlc.com
sudo cp /etc/letsencrypt/live/elasticsearch.apps.$GUID.dynamic.opentlc.com/{cert,fullchain,chain,privkey}.pem ~/demo/demo.redhat.com/
sudo chown $GUID-user ~/demo/demo.redhat.com/ -R

sudo cp ~/demo/demo.redhat.com/nginx.repo /etc/yum.repos.d/nginx.repo
sudo yum-config-manager --enable nginx-mainline
sudo yum install -y nginx
cat ~/demo/demo.redhat.com/nginx.conf.template | \
  perl -pe "s/\{\{ guid \}\}/$GUID/g" | \
  perl -pe "s/\{\{ bastion \}\}/127.0.01/g" | \
  perl -pe "s/\{\{ cluster \}\}/$(dig dns.apps.ocp.example.com +short)/g" | \
  sudo tee /etc/nginx/nginx.conf > /dev/null
sudo systemctl enable nginx --now

mkdir ~/.kube/
sudo cp /home/lab-user/install/auth/kubeconfig ~/.kube/config
sudo chown $GUID-user: ~/.kube/config
