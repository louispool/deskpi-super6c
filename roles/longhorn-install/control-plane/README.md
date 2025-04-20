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
3. Configures the Linkerd Service Mesh (if `k3s_enable_service_mesh` is set to `true`).  
4. Prefer the `longhorn storage class` as default by setting the `local-path storage` class as **non**-default.
5. Exposes the Longhorn Dashboard via 
   - an IngressRoute on the local network
   - an IngressRoute on the internet (if `enable_public_longhorn_dashboard` is set to `true`).

### Configuration

Configure the namespace for the Longhorn deployment via the variable `k3s_longhorn_namespace`:
```yaml
k3s_longhorn_namespace: longhorn-system
```

Configure whether to enable the Linkerd service mesh via the variable `k3s_enable_service_mesh`:
```yaml
k3s_enable_service_mesh: true
```

Configure the user and password for the BasicAuth middleware used to access the Longhorn Dashboard:
```yaml
longhorn_basic_auth_user: admin
longhorn_basic_auth_passwd: passwd
```   

Configure the lcoal domain for the Longhorn Dashboard via the variable `longhorn_dashboard`:
```yaml
longhorn_dashboard: longhorn.deskpi.localnet
```

Configure the public domain for the Traefik Dashboard via the variable `public_traefik_dashboard`:
```yaml
public_traefik_dashboard: traefik.deskpi.localnet
```

Configure whether to allow access to the Longhorn dashboard over the public network
```yaml
enable_public_traefik_dashboard: false      
```

The helm values for the Longhorn deployment can be tweaked in the [`templates/longhorn-helm-values.yml.j2`](templates/longhorn-helm-values.yml.j2) file. 

### References

- https://longhorn.io/docs/1.4.0/deploy/install/install-with-helm/
- https://picluster.ricsanfre.com/docs/longhorn/#installation-procedure-using-helm
- https://rpi4cluster.com/k3s/k3s-storage-setting/