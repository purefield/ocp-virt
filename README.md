Openshift Virtualization Demo running Elasticsearch on mixed nodes (vm and containers)

![Elasticsearch Cluster Overview](hybrid-virt-elasticsearch.png)

### Dependencies:
OpenShift Virtualization Operator
Cert Util Operator
* OpenShift virtualization cluster with ODF (default storage class set and profile applied)
* RHEL Subscription information for 
** Subscription Org
** Subscription Key

### Demo
```sh
sudo dnf install -y git
git clone https://github.com/purefield/opc-virt.git ~/demo
cd ~/demo/
./setup.sh
```

### Setup
Log into OpenShift Cluster
Run the demo script to create a fresh elasticsearch cluster in a new namespace (first argument or prompt, defaults to last namespace used or ```next-gen-virt```)
```sh
cd elasticsearch/
./generate-yaml.sh next-gen-virt
```
