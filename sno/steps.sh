sysctl net.ipv4.ip_forward=1
perl -pe 's/#(net.ipv4.ip_forward=1)/$1/' /etc/sysctl.conf
ssh-keygen -N ""  -f id_rsa
ssh-keygen -R 192.168.100.2
ssh core@192.168.100.2 -i id_rsa sudo journalctl -u agent.service -f
ssh-keygen -R 192.168.100.3
ssh core@192.168.100.3 -i id_rsa sudo journalctl -u agent.service -f

# Accept worker node to cluster
oc get nodes
oc get csr
oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs --no-run-if-empty oc adm certificate approve
oc get csr
oc get nodes

# CoreDNS
podman pull coredns/coredns
/usr/bin/podman run --rm --name coredns --read-only -p 53:53/tcp -p 53:53/udp -v ./coredns:/etc/coredns:ro --cap-drop ALL --cap-add NET_BIND_SERVICE coredns/coredns -conf /etc/coredns/Corefile
<<<<<<< Updated upstream
podman generate systemd coredns
=======
podman generate systemd coredns > /etc/systemd/system/coredns.service
systemctl daemon-reload
systemctl enable coredns --now

>>>>>>> Stashed changes

# dnsmasq
virsh net-list --all
virsh net-define dnsmasq/ocp.net.xml --validate
virsh net-define dnsmasq/ocp.net.xml
virsh net-edit ocp
virsh net-destroy ocp && virsh net-start ocp

# firewall-cmd port forward
firewall-cmd --add-forward-port=port=443:proto=tcp:toport=443:toaddr=192.168.100.2 --permanent
firewall-cmd --add-masquerade --permanent
firewall-cmd --remove-forward-port=port=443:proto=tcp:toport=443:toaddr=192.168.100.2 --permanent
firewall-cmd --remove-masquerade --permanent
firewall-cmd --list-all
firewall-cmd --add-service=https --zone=public --permanent
firewall-cmd --reload
