sudo dnf install -y git
git clone https://github.com/purefield/opc-virt.git ~/demo
ssh-keygen -N ""  -f ~/demo/demo.id_rsa
echo "export subscriptionOrg=???
export subscriptionKey=???" > ~/demo/subscription.txt

