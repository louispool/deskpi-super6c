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

This [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) definition leverages the [nfs-subdir-external-provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) to create a kubernetes storage class that can dynamically 
create a persistent volume using an NFS export.

You can use this role to create a storage class using either a remote NFS server or you a locally configured NFS server.

In contrast to manually creating a persistent volume and persistent volume claim, this dynamic method cedes the lifecycle
of the persistent volume over to the storage class itself.

This can be used as an external storage for AlertManager and Prometheus, ensuring multi-node level durability (of the storage).

### Configuration

To configure the Host as a local NFS Server, set the variable: 
```
local_nfs_server: true
```

To set the location of a remote NFS Server, configure the variables:
```
local_nfs_server: false
nfs_server: <ip_address_of_nfs>
```
And ensure the path to the share is correct:
```
nfs_path: <path_to_share>
```

To check the NFS export you can use the following command:
```
/sbin/showmount -e <ip_address_of_nfs> 
```
For example, to show the NFS exports for a local NFS server the command would be:
```
/sbin/showmount -e localhost
```
 
### Testing
            
After the role has been executed, you can check the storage class created by running the following command:
```
kubectl get storageclass
```
You should see the storage class `nfs-client` listed
```
NAME                   PROVISIONER                                                     RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path                                           Delete          WaitForFirstConsumer   false                  22h
nfs-client             cluster.local/nfs-provisioner-nfs-subdir-external-provisioner   Delete          Immediate              true                   22h
```

To test the NFS storage class, you can create a yaml file, called `test-pvc.yaml` for example, containing persistent volume claim using the storage class created by this role:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: nfs-client
  resources:
    requests:
      storage: 2Gi
``` 
And then applying the file:
```bash
kubectl apply -f test-pvc.yaml
```

### References

https://fabianlee.org/2022/01/12/kubernetes-nfs-mount-using-dynamic-volume-and-storage-class/