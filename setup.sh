sudo dnf install -y git
git clone https://github.com/purefield/opc-virt.git ~/demo
ssh-keygen -N ""  -f ~/demo/demo.id_rsa
echo "export subscriptionOrg=???
export subscriptionKey=???" > ~/demo/subscription.txt
sudo cp ~/demo/demo.redhat.com/demo.conf /etc/httpd/conf.d/demo.conf
sudo sytemctl reload httpd
