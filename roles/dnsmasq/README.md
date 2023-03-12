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

### References

- https://thekelleys.org.uk/dnsmasq/doc.html
- https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html
- https://wiki.archlinux.org/title/dnsmasq
- https://www.linux.com/topic/networking/advanced-dnsmasq-tips-and-tricks


