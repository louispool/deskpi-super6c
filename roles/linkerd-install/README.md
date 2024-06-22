# Role definition for installing the [Linkerd](https://linkerd.io/) Control Plane

```
├── roles
│  ├── linkerd-install
|  |  ├── control-plane
|  |  |  ├── defaults
|  |  |  |  ├── main.yml
|  |  |  ├── tasks 
|  |  |  |  ├── main.yml  
|  |  |  ├── templates
|  |  |  |  ├── linkerd-identity-issuer.yml.j2
|  |  |  |  ├── linkerd-namespace.yml.j2
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for installing [Linkerd](https://linkerd.io/), a service mesh for Kubernetes. It makes running services easier and safer by giving you runtime debugging, observability, reliability, and security.
   
### Synopsis
This role contains tasks that will 

1. Install the [Linkerd CLI](https://linkerd.io/2.12/getting-started/#step-1-install-the-cli)

2. Create the following Kubernetes resources: 
    - [linkerd-namespace.yml](templates/linkerd-namespace.yml.j2) -
   Since we are manually creating the namespace we need to duplicate the annotations mentioned [here](https://github.com/linkerd/linkerd2/blob/main/charts/linkerd-control-plane/templates/namespace.yaml).
    - [linkerd-identity-issuer.yml](templates/linkerd-identity-issuer.yml.j2) - A certificate resource referencing the [Certificate Authority Issuer](../../cert-manager-install/templates/ca-issuer.yml.j2) created during installation of [cert-manager](../../cert-manager-install/README.md).

3. Retrieve the CA certificate used to sign the *linkerd-identity-issuer* certificate.<br> 
   When installing Linkerd we need to supply the [*trust-anchor*](https://linkerd.io/2.12/tasks/install-helm/#prerequisite-generate-identity-certificates) (root certificate) used to sign the `linkerd-identity-issuer`. We can obtain this from the associated secret via the following command:
    ```bash
    kubectl get secret linkerd-identity-issuer -o jsonpath="{.data.ca\.crt}" | base64 -d > ca.crt
    ```
   
4. Install the [Linkerd CRDs](https://linkerd.io/2.12/tasks/install-helm/#linkerd-crds) using Helm.
5. Install the [Linkerd Control Plane](https://linkerd.io/2.12/tasks/install-helm/#linkerd-crds) using Helm.

### References

https://linkerd.io/2.12/getting-started/
https://picluster.ricsanfre.com/docs/service-mesh/






