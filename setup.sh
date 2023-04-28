sudo dnf install -y git
git clone https://github.com/purefield/opc-virt.git ~/demo
ssh-keygen -N ""  -f ~/demo/demo.id_rsa
echo "export subscriptionOrg=???
export subscriptionKey=???" > ~/demo/subscription.txt
perl -pe "s/\{\{ guid \}\}/$GUID/g" ~/demo/demo.redhat.com/demo.conf.template | sudo tee /etc/httpd/conf.d/demo.conf > /dev/null
sudo systemctl reload httpd
