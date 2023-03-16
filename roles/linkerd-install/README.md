# Roles for the installation of the [Linkerd](https://linkerd.io/) Service Mesh

```
├── roles
│  ├── linkerd-install
|  |  ├── control-plane
|  |  |  ├── defaults
|  |  |  |  ├── ...
|  |  |  ├── tasks 
|  |  |  |  ├── ...
|  |  ├── linkerd-viz
|  |  |  ├── defaults
|  |  |  |  ├── ...
|  |  |  ├── tasks 
|  |  |  |  ├── ...
|  |  |  ├── templates
|  |  |  |  ├── ...
```

This structure houses the [Ansible Roles](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for
installing [Linkerd](https://linkerd.io/), a service mesh for Kubernetes.

Consisting of the following roles:

- [linkerd-install/control-plane](./control-plane/README.md) installs the Linkerd Control-Plane.
- [linkerd-install/linkerd-viz](./linkerd-viz/README.md) installs Linkerd's "viz" extension. 

### References
- https://linkerd.io/2.12/getting-started/
