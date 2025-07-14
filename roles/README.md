# [Ansible Roles](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles)

```
├── roles
│  ├── <role-name>
│  |  ├── defaults
|  |  |  ├── main.yml
│  |  ├── files
│  |  |  ├── ...
│  |  ├── handlers
|  |  |  ├── main.yml
│  |  ├── tasks
|  |  |  ├── main.yml
│  |  ├── vars
|  |  |  ├── main.yml
│  |  ├── templates
|  |  |  ├── *.yml.j2
│  |  ├── tests
│  |  |  ├── ...
```

This structure houses the roles used by the [Ansible Playbooks](../playbooks/README.md).

### Index of Role Definitions

#### Roles for Package Installation/Uninstallation

- [Cluster pre-installation](cluster-pre-install/README.md) (before k3s installation)
- [Cluster post-installation](cluster-post-install/README.md) (after k3s installation)
- [Installation of Cert-Manager](./cert-manager-install/README.md)
- [Uninstallation of Cert-Manager](./cert-manager-uninstall/README.md)
- [Installation of MetalLB](./metallb-install/README.md) (Load Balancer)
- [Uninstallation of MetalLB](./metallb-uninstall/README.md) (Load Balancer)
- [Installation of Traefik](./traefik-install/README.md) (Ingress Controller)
- [Uninstallation of Traefik](./traefik-uninstall/README.md) (Ingress Controller)
- [Installation of Longhorn](./longhorn-install/README.md) (Storage Controller)
- [Uninstallation of Longhorn](./longhorn-uninstall/README.md) (Storage Controller)
- [Installation of Prometheus](./prometheus-install/README.md) (Monitoring)
- [Uninstallation of Prometheus](./prometheus-uninstall/README.md) (Monitoring)
- [Installation of OpenSearch](./opensearch-install/README.md) (Logging)
- [Uninstallation of OpenSearch](./opensearch-uninstall/README.md) (Logging)
- [Installation of Minio](./minio-install/README.md) (S3 Object Storage)
- [Uninstallation of Minio](./minio-uninstall/README.md) (S3 Object Storage)
- [Installation of Linkerd](./linkerd-install/README.md) (Service Mesh)
- [Uninstallation of Linkerd](./linkerd-uninstall/README.md) (Service Mesh)
             
#### Other Roles

- [DNS Server installation](./dnsmasq/README.md)
- [NTP Server/Client installation](./chrony/README.md)
- [HELM installation](./helm/README.md)
- [Traefik Basic Auth Middleware](./traefik-basic-auth/README.md)
- [Setting up Route53 DDNS](./route53-ddns-install/README.md)
- [Undoing Route53 DDNS](./route53-ddns-uninstall/README.md)

 