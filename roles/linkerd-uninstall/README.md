# Role definition for uninstalling the [Linkerd](https://linkerd.io/).

```
├── roles
│  ├── linkerd-uninstall
│  │  ├── defaults
│  │  │  ├── main.yml
│  │  ├── tasks 
│  │  │  ├── main.yml  
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for uninstalling [Linkerd](https://linkerd.io/), a service mesh for Kubernetes. 
                     
### Synopsis

This role contains tasks that will 

1. Remove the Linkerd extensions (e.g. viz)
2. Remove the Linkerd control-plane

Before executing this role, the Linkerd data-plane proxies should be removed. This is done by removing the [Linkerd proxy injection](https://linkerd.io/2.12/features/proxy-injection/) annotations from the deployments and rolling them.  

### References

https://linkerd.io/2.12/tasks/uninstall/