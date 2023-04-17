# Role definition for installing the [Traefik](https://traefik.io/) Ingress Controller.

```
├── roles
│  ├── traefik-install
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── tasks 
|  |  |  ├── basic_auth_credentials.yml
|  |  |  ├── main.yml  
|  |  ├── templates
|  |  |  ├── basic-auth-middleware.yml.j2
|  |  |  ├── http-redirect-middleware.yml.j2
|  |  |  ├── traefik-dashboard.yml.j2
|  |  |  ├── traefik-helm-values.yml.j2
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for installing [Traefik](https://github.com/traefik/traefik-helm-chart), a modern HTTP reverse proxy and load balancer.

### Synopsis

This role does the following:

1. Creates a namespace for the Traefik deployment.
2. Deploys the [Traefik Helm chart](https://github.com/traefik/traefik-helm-chart#installing) with values that specify:
   - the enabling of access logs
   - the deployment of a sidecar container for access logging
   - the enabling of a dedicated metrics service for use with Prometheus
   - the enabling of cross namespace references
3. Generates a base64 encoded `user:password` pair using the [htpasswd](https://httpd.apache.org/docs/2.4/programs/htpasswd.html) utility.
4. Configures [BasicAuth middleware](https://doc.traefik.io/traefik/middlewares/http/basicauth/) using the `user:password` pair.
6. Configures [HTTP-to-HTTPS redirect middleware](https://doc.traefik.io/traefik/middlewares/http/redirectscheme/)
7. Configures a Certificate and an [IngressRoute](https://doc.traefik.io/traefik/providers/kubernetes-crd/) to the [Traefik Dashboard](https://doc.traefik.io/traefik/operations/api/#configuration). 

### References

- https://github.com/traefik/traefik-helm-chart#installing
- https://picluster.ricsanfre.com/docs/traefik/