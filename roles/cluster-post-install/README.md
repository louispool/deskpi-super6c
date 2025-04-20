# Ansible Role definition for tasks to be run *after* k3s installation

```
├── roles
│  ├── cluster-post-install
|  |  ├── handlers
|  |  |  ├── main.yml
|  |  ├── tasks 
|  |  |  ├── main.yml  
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for the various tasks that prepare the DeskPi cluster **after**
k3s installation.

### Synopsis

This role does the following:

- Ensures [CoreDNS](https://docs.k3s.io/networking/networking-services#coredns) is running with at least 2 replicas
- Ensures [CoreDNS](https://docs.k3s.io/networking/networking-services#coredns) is forwarding DNS requests to public DNS servers


