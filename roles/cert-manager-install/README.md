# Role definition for installing [cert-manager](https://cert-manager.io/).

```
├── roles
│  ├── cert-manager-install
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── tasks 
|  |  |  ├── main.yml  
|  |  ├── templates
|  |  |  ├── self-signed-issuer.yml.j2
|  |  |  ├── lets-encrypt-issuer.yml.j2
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for installing the [cert-manager](https://cert-manager.io/) package, which automates the management, issuance, and renewal of TLS certificates.
It adds certificates and certificate issuers as resource types in Kubernetes clusters, and simplifies the process of obtaining, renewing and using those certificates. 
It works with multiple certificate issuers, including Let's Encrypt, self-signed certificates, and internal PKI authorities.

In a K3s cluster, cert-manager integrates seamlessly with Traefik, enabling automatic TLS for Ingress resources.

![Certificate Management](cert-management.svg)

### Synopsis

This role does the following:

1. Creates a namespace for the cert-manager deployment.
2. Deploys the [cert-manager Helm chart](https://cert-manager.io/docs/installation/helm/).
3. Configures the CRD's:
    - ClusterIssuer for the Self-Signed Issuer.
    - Certificate and ClusterIssuer for the Private CA (Certificate Authority).
    - ClusterIssuer for Let's Encrypt (if enabled)
  
### Configuration

Configure the namespace for the cert-manager deployment via the variable `k3s_cert_manager_namespace`:
```yaml
k3s_cert_manager_namespace: cert-manager-system
```

Configure enabling the self-signed Certificate Issuer:
```yaml
enable_selfsigned: true
```

Configure enabling the `Let's Encrypt` ACME (Automated Certificate Management Environment) provider
```yaml
enable_letsencrypt: false
```

Configure the email address for Let's Encrypt certificate issuance via the variable `acme_email`. 
```yaml
acme_email=your_email@mail.com
```   
Let's Encrypt will use this to contact you about expiring certificates and issues related to your account.

### Testing

Verify the installation by running the command:
```shell
kubectl get pods -n cert-manager-system
```

You should see three pods running in the `cert-manager-system` namespace:
```shell
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-7f9d96d7b8-xyzxx              1/1     Running   0          1m
cert-manager-cainjector-5ff6c59d4b-kjxxm   1/1     Running   0          1m
cert-manager-webhook-6b5b5f65c8-xjzkk      1/1     Running   0          1m
```

### References

https://cert-manager.io/docs/installation/helm/
https://picluster.ricsanfre.com/docs/certmanager/
