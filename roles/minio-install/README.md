# Role definition for installing [MinIO](https://min.io/).

```
├── roles
│  ├── minio-install
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── tasks 
|  |  |  ├── main.yml  
|  |  ├── templates
|  |  |  ├── minio-helm-operator-values.yml.j2
|  |  |  ├── minio-helm-tenant-values.yml.j2
```

[Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) definition for installing [*MinIO*](https://min.io/docs/minio/kubernetes/upstream/operations/install-deploy-manage/deploy-operator-helm.html), an s3 object store.

### Synopsis

This role does the following: 

1. Creates a namespace for the MinIO Operator deployment.
2. Deploys the [MinIO Operator Helm chart](https://github.com/minio/operator/tree/master/helm/operator) with an ingress role for the operator-console.
3. Creates a namespace for the MinIO Tenant deployment 
4. Deploys the [MinIO Tenant Helm chart](https://github.com/minio/operator/tree/master/helm/tenant) with an ingress role for the tenant-console.

### Login

The *jwt* token for logging into the minio operator console (default dns: https://minio.k3s.int.diamos.com) can be retrieved with

```
kubectl -n minio-operator-system get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode
```

The default login for the tenant console (default dns: https://minio-tenant-console.k3s.int.diamos.com) 
is the user ```minio``` and the password ```minio123```.

### References

- https://min.io/docs/minio/kubernetes/upstream/operations/install-deploy-manage/deploy-operator-helm.html
- https://github.com/minio/operator/tree/master/helm
