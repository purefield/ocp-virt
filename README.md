Openshift Virtualization Demo running Elasticsearch on mixed nodes (vm and containers)

![Elasticsearch Cluster Overview](hybrid-virt-elasticsearch.png)

### Dependencies:
* OpenShift virtualization cluster with ODF (default storage class set and profile applied)
* ```./demo.id_rsa``` - private key for vm access
* ```./demo.id_rsa.pub``` - public key for vm access
* ```./subscription.txt``` - export values for ```subscriptionOrg``` and ```subscriptionKey```

### Setup
Log into OpenShift Cluster
Create cluster in new namespace (first argument or prompt, defaults to last namespace used or ```next-gen-virt```)
```sh
cd elasticsearch/
./generate-yaml.sh next-gen-virt
```
