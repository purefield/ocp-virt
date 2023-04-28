sudo dnf install -y git python3-certbot-apache
git clone https://github.com/purefield/opc-virt.git ~/demo
ssh-keygen -N ""  -f ~/demo/demo.id_rsa
echo "export subscriptionOrg=???
export subscriptionKey=???" > ~/demo/subscription.txt
perl -pe "s/\{\{ guid \}\}/$GUID/g" ~/demo/demo.redhat.com/letsencrypt.conf.template | sudo tee /etc/httpd/conf.d/letsencrypt.conf > /dev/null
sudo systemctl reload httpd
sudo letsencrypt certonly --apache --agree-tos --email email@example.com \
  -d elasticsearch.apps.$GUID.dynamic.opentlc.com \
  -d coordinate.apps.$GUID.dynamic.opentlc.com \
  -d kibanan.apps.$GUID.dynamic.opentlc.com \
  -d es-master00.apps.$GUID.dynamic.opentlc.com \
  -d es-master01.apps.$GUID.dynamic.opentlc.com \
  -d es-master02.apps.$GUID.dynamic.opentlc.com
perl -pe "s/\{\{ guid \}\}/$GUID/g" ~/demo/demo.redhat.com/demo.conf.template | sudo tee /etc/httpd/conf.d/demo.conf > /dev/null
sudo systemctl reload httpd
