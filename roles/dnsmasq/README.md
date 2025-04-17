# Role definition for installing a local [DNS server](https://thekelleys.org.uk/dnsmasq/doc.html).

```
├── roles
│  ├── dnsmasq
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── handlers 
|  |  |  ├── main.yml  
|  |  ├── tasks 
|  |  |  ├── main.yml  
|  |  ├── templates
|  |  |  ├── dnsmasq.conf.j2
```

[Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) definition for setting up a DNS server, using [*dnsmasq*](https://thekelleys.org.uk/dnsmasq/doc.html), a lightweight DNS, TFTP, PXE, router advertisement and DHCP server, intended for small networks.

### Configuration
                   
The role template [`dnsmasq.conf.j2`](templates/dnsmasq.conf.j2) is used to generate the configuration file which configures `dnsmasq`. The following is a listing of some of the 
facts that can be set to configure the DNS server.
  
#### General Configuration Options 
Specify the network interface (e.g. `eth0`, `eth1`, `wlan0` etc.) to listen on via the variable `dnsmasq_interface`:
```yaml
dnsmasq_interface: 'eth0'
```
Leave empty if the default interface on the host should be used.

Specify the IP address to listen on via the variable `dnsmasq_listen_address`:
```yaml
dnsmasq_listen_address: '192.168.1.100`
```
Leave empty if the default IP address on the host should be used.

The path to the main configuration file should typically be left as is:
```yaml
dnsmasq_conf_dir: '/etc/dnsmasq.d/'
```
                                   
#### DNS Configuration Options

Upstream name servers can be specified via the variable `upstream_dns_servers`:
```yaml
upstream_dns_servers:
  - 1.1.1.1
  - 8.8.8.8
```
            
The two variables for the local domain name, `local_domain` and `cluster_local_domain` define your local network's domain:
```yaml
local_domain: 'localnet'
cluster_local_domain: 'cluster.local'
```
    
The variable `gateway` specifies the IP address of the network's gateway, while `k3s_ingress_external_ip` specifies the external IP for Kubernetes Ingress (typically used by Traefik)
```yaml
gateway: "192.168.1.1"
k3s_ingress_external_ip: "192.168.1.100"
```

Calls to the `local_domain` will resolve to the IP address of your network's gateway, while calls to the `cluster_local_domain` will resolve to the IP address for Kubernetes Ingress.

Subdomains of these domains are resolved their respective IP addresses via DNS wildcard. In other words, given the above example, `test.cluster.local` will resolve to the IP address of the 
Kubernetes Ingress `192.168.1.100`.
              
Additional DNS records can be specified via the fact `additional_dns_hosts`:
```yaml
additional_dns_hosts:
  ntp_server:
    desc: "NTP Server"
    hostname: ntp
    ip: 10.0.0.1
  dns_server:
    desc: "DNS Server"
    hostname: dns
    ip: 10.0.0.1
```

#### DHCP Configuration Options

If you want to use the DNS server as a DHCP server, you must enable the following variable:
```yaml
enable_dhcp: true
```

The dhcp range can be specified via the fact `dhcp_range` and should not overlap with the IP addresses used by the Loadbalancer (e.g. MetalLB), for example:
```yaml
dhcp_range: "192.168.1.10,192.168.1.100"
```

Note that, if enabled, DHCP will also be configured based on your inventory.

### Testing

There is a playbook available in the [tests](tests/test-dnsmasq-conf.yml) directory with which you can test the generation of the `dnsmasq.conf` file,
run the following command from the project root directory:
```shell
ansible-playbook roles/dnsmasq/tests/test-dnsmasq-conf.yml
```

To clean up resources created by the test, run the following command:
```shell
ansible-playbook roles/dnsmasq/tests/cleanup.yml
```

### References

- https://thekelleys.org.uk/dnsmasq/doc.html
- https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html
- https://wiki.archlinux.org/title/dnsmasq
- https://www.linux.com/topic/networking/advanced-dnsmasq-tips-and-tricks


