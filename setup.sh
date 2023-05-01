sudo dnf install -y git python3-certbot-apache nginx
git clone https://github.com/purefield/opc-virt.git ~/demo
ssh-keygen -N ""  -f ~/demo/demo.id_rsa
echo "export subscriptionOrg=???
export subscriptionKey=???" > ~/demo/subscription.txt
perl -pe "s/\{\{ guid \}\}/$GUID/g" ~/demo/demo.redhat.com/letsencrypt.conf.template | sudo tee /etc/httpd/conf.d/letsencrypt.conf > /dev/null
perl -pe "s/443/444/" /etc/httpd/conf.d/ssl.conf
sudo systemctl reload httpd
sudo letsencrypt certonly --apache --agree-tos --email email@example.com \
  -d elasticsearch.apps.$GUID.dynamic.opentlc.com \
  -d coordinate.apps.$GUID.dynamic.opentlc.com \
  -d kibana.apps.$GUID.dynamic.opentlc.com \
  -d es-master00.apps.$GUID.dynamic.opentlc.com \
  -d es-master01.apps.$GUID.dynamic.opentlc.com \
  -d es-master02.apps.$GUID.dynamic.opentlc.com
 
cat ~/demo/demo.redhat.com/nginx.conf.template | \
  perl -pe "s/\{\{ guid \}\}/$GUID/g" | \
  perl -pe "s/\{\{ bastion \}\}/127.0.01/g" | \
  perl -pe "s/\{\{ cluster \}\}/$(dig dns.apps.ocp.example.com +short)/g" | \
  sudo tee /etc/nginx/conf.d/demo.conf > /dev/null
sudo systemctl reload nginx
