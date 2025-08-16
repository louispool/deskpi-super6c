# Roles for the installation of the [Longhorn](https://longhorn.io/) Storage Controller.

```
├── roles
│  ├── longhorn-install
│  │  ├── cluster-prep
│  │  │  ├── defaults
│  │  │  │  ├── ...
│  │  │  ├── tasks 
│  │  │  │  ├── ...
│  │  ├── control-plane
│  │  │  ├── defaults
│  │  │  │  ├── ...
│  │  │  ├── tasks 
│  │  │  │  ├── ...
│  │  │  ├── templates
│  │  │  │  ├── ...
```

This structure houses the [Ansible Roles](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for installing [Longhorn](https://github.com/longhorn/longhorn), a lightweight, reliable and easy-to-use distributed block storage system for Kubernetes.

Consisting of the following roles:

- [longhorn-install/cluster-prep](./cluster-prep/README.md) for the preparation of the cluster prior to the installation of Longhorn.
- [longhorn-install/control-plane](./control-plane/README.md) installs the Longhorn Control-Plane. 

**Note** that these roles contains tasks that will **WIPE THE DISK** configured for use by Longhorn! Be extra careful before executing these roles and make sure that you have set all the variables properly.

### References

- https://longhorn.io/docs/1.4.0/deploy/install/install-with-helm/
- https://picluster.ricsanfre.com/docs/longhorn/#installation-procedure-using-helm
- https://rpi4cluster.com/k3s/k3s-storage-setting/