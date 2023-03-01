# Role definition for installing [MetalLB](https://metallb.universe.tf/).

```
├── roles
│  ├── metallb-install
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── tasks 
|  |  |  ├── main.yml  
|  |  ├── templates
|  |  |  ├── metallb-config.yml.j2
```

[Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) definition for installing [*MetalLB*](https://metallb.universe.tf/installation/), a load-balancer implementation for bare metal Kubernetes clusters.

### References

https://metallb.universe.tf/installation/
