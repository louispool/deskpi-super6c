# Role definition for uninstalling [cert-manager](https://cert-manager.io/)

```
├── roles
│  ├── cert-manager-uninstall
│  │  ├── tasks 
│  │  │  ├── main.yml  
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for [uninstalling cert-manager](https://cert-manager.io/docs/installation/helm/#uninstalling).

This role uninstalls `cert-manager` via Helm, removes all Certificates, Certificate Requests, Orders, Challenges, Issuers, and ClusterIssuers, 
and deletes the cert-manager namespace.

### References

https://cert-manager.io/docs/installation/helm/#uninstalling