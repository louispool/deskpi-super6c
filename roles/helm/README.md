# Role definition for installing [Helm](https://helm.sh/).

```
├── roles
│  ├── helm
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── tasks 
|  |  |  ├── main.yml  
```

[Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) definition for installing [*Helm*](https://helm.sh/docs/intro/install/), the package manager for Kubernetes.

This role downloads the version of the Helm binary defined by the variable `helm_version` and copies it to the location defined by the variable `helm_bin_path`. 

### References

https://helm.sh/docs/intro/install/


