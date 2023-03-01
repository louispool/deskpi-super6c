# Role definition for installing the [Linkerd](https://linkerd.io/) *viz* extension

```
├── roles
│  ├── linkerd-install
|  |  ├── linkerd-viz
|  |  |  ├── defaults
|  |  |  |  ├── main.yml
|  |  |  ├── tasks 
|  |  |  |  ├── main.yml  
|  |  |  ├── templates
|  |  |  |  ├── linkerd-viz-ingress.yml.j2
|  |  |  |  ├── linkerd-viz-namespace.yml.j2
|  |  |  |  ├── linkerd-viz-prometheus.yml.j2
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for installing Linkerd's ["viz" extension](https://linkerd.io/2.12/features/dashboard/) a full on-cluster metricsstack, including CLI tools and a web dashboard.

### [linkerd-viz-namespace.yml](templates/linkerd-namespace.yml.j2)

Since we are manually creating the namespace we need to duplicate the annotations mentioned in the [chart](https://github.com/linkerd/linkerd2/blob/main/viz/charts/linkerd-viz/templates/namespace.yaml).

### [linkerd-identity-issuer.yml](templates/linkerd-identity-issuer.yml.j2)

A certificate resource referencing the [Certificate Authority Issuer](../../cert-manager-install/templates/ca-issuer.yml.j2) created during installation of [cert-manager](../../cert-manager-install/README.md).







