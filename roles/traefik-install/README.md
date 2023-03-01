# Role definition for installing the [Traefik](https://traefik.io/) Ingress Controller.

```
├── roles
│  ├── traefik-install
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── tasks 
|  |  |  ├── main.yml  
|  |  ├── templates
|  |  |  ├── ca-issuer.yml.j2
|  |  |  ├── self-signed-issuer.yml.j2
|  |  |  ├── lets-encrypt-issuer.yml.j2
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for installing [Traefik](https://github.com/traefik/traefik-helm-chart), a modern HTTP reverse proxy and load balancer.

### References

https://github.com/traefik/traefik-helm-chart#installing





