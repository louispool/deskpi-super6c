# Role definition for cluster preparation prior to the installation of [Longhorn](https://longhorn.io/).

```
├── roles
│  ├── longhorn-install
|  |  ├── cluster-prep
|  |  |  ├── defaults
|  |  |  |  ├── main.yml
|  |  |  ├── tasks 
|  |  |  |  ├── install_prereqs.yml
|  |  |  |  ├── main.yml  
|  |  |  |  ├── prepare_disk.yml
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for
preparing the cluster for the installation of [Longhorn](https://github.com/longhorn/longhorn), a lightweight, reliable and easy-to-use distributed block storage system for Kubernetes.

### Synopsis

This role does the following:

1. Installs and loads the modules [required by Longhorn](https://longhorn.io/docs/1.4.0/deploy/install/#installation-requirements) (i.e. 'iscsi' and 'nfs')
2. If the mount defined by `longhorn_storage_path` is not mounted, prepares the disk device (defined by the variable`longhorn_disk_device`) on a host in the cluster by:
   - wiping it
   - formatting it to ext4/xfs
   - setting a mount point

**Note** that these tasks will **WIPE THE DISK!** Be extra careful before executing this role and make sure that you have set all the variables properly.

### References

- https://longhorn.io/docs/1.4.0/deploy/install/install-with-helm/
- https://picluster.ricsanfre.com/docs/longhorn/#installation-procedure-using-helm
- https://rpi4cluster.com/k3s/k3s-storage-setting/