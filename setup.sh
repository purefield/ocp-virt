sudo dnf install -y git
git clone https://github.com/purefield/opc-virt.git ~/demo
ssh-keygen -N ""  -f ~/demo/demo.id_rsa
echo "export subscriptionOrg=???
export subscriptionKey=???" > ~/demo/subscription.txt
echo "" > ~/demo/demo.redhat.com/demo.conf
for name in es-master00 es-master01 es-master02 coordinate elasticsearch kibana; do
  cat ~/demo/demo.redhat.com/demo.conf.template | \
    perl -pe "s/\{\{ guid \}\}/$GUID/g" | \
    perl -pe "s/\{\{ name \}\}/$name/g" >> ~/demo/demo.redhat.com/demo.conf
done
sudo cp ~/demo/demo.redhat.com/demo.conf /etc/httpd/conf.d/demo.conf
sudo systemctl reload httpd
