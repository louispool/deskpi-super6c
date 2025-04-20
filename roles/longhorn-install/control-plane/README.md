# Role definition for installing the [Longhorn](https://longhorn.io/) Storage Controller.

```
├── roles
│  ├── longhorn-install
│  │  ├── control-plane
│  |  |  ├── defaults
│  |  |  |  ├── main.yml
│  |  |  ├── tasks 
│  |  |  |  ├── configure_service_mesh.yml
│  |  |  |  ├── main.yml  
│  |  |  ├── templates
│  |  |  |  ├── longhorn-helm-values.yml.j2
│  |  |  |  ├── longhorn-ui-ingress.yml.j2
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for
installing [Longhorn](https://github.com/longhorn/longhorn), a lightweight, reliable and easy-to-use distributed block storage system for Kubernetes.
           
Assumes the [longhorn/cluster-prep](../cluster-prep/README.md) role was previously run.     

### Synopsis

This role does the following:

1. Creates a namespace for the Longhorn deployment.
2. Deploys the [Longhorn Helm chart](https://longhorn.io/docs/1.4.0/deploy/install/install-with-helm/) with values that specify:
    - the location of the mount point on the DeskPi's
3. Configures an Ingress for accessing the [Longhorn UI](https://longhorn.io/docs/1.4.0/deploy/accessing-the-ui/).
4. Configures the Linkerd Service Mesh (if `k3s_enable_service_mesh` is set to `true`).  
5. Prefer the `longhorn storage class` as default by setting the `local-path storage` class as **non**-default.

### References

- https://longhorn.io/docs/1.4.0/deploy/install/install-with-helm/
- https://picluster.ricsanfre.com/docs/longhorn/#installation-procedure-using-helm
- https://rpi4cluster.com/k3s/k3s-storage-setting/