# Role definition for uninstalling [Longhorn](https://longhorn.io/)

```
├── roles
│  ├── longhorn-uninstall
|  |  ├── tasks 
|  |  |  ├── main.yml  
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles)
for [uninstalling Longhorn](https://longhorn.io/docs/1.4.0/deploy/uninstall/).
  

This role may lead to data loss, to prevent damage to the k8s cluster, ensure that all workloads using Longhorn have been deleted. 


### References

https://longhorn.io/docs/1.4.0/deploy/uninstall/