# Role definition for installing an NFS Storage Class for Kubernetes.

```
├── roles
│  ├── nfs-storage
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── tasks 
|  |  |  ├── configure_local_nfs_server.yml
|  |  |  ├── main.yml  
```

This [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) definition leverages the [nfs-subdir-external-provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) to create a kubernetes storage class that can dynamically create a persistent volume.

In contrast to manually creating a persistent volume and persistent volume claim, this dynamic method cedes the lifecycle
of the persistent volume over to the storage class itself.

This can be used as an external storage for AlertManager and Prometheus, ensuring multi-node level durability (of the storage).

### Configuration

To configure the Host as a local NFS Server, set the fact: 
```
local_nfs_server: true
```

To set the location of a remote NFS Server, set the facts:

```
local_nfs_server: false
nfs_server: <ip_address_of_nfs>
```
And ensure the path to the share is correct:
```
nfs_path: <path_to_share>
```

### References

https://fabianlee.org/2022/01/12/kubernetes-nfs-mount-using-dynamic-volume-and-storage-class/