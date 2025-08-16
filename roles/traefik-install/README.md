# Role definition for installing the [Traefik](https://traefik.io/) Ingress Controller

```
├── roles
│  ├── traefik-install
│  │  ├── defaults
│  │  │  ├── main.yml
│  │  ├── tasks 
│  │  │  ├── basic_auth_credentials.yml
│  │  │  ├── main.yml  
│  │  ├── templates
│  │  │  ├── basic-auth-middleware.yml.j2
│  │  │  ├── http-redirect-middleware.yml.j2
│  │  │  ├── traefik-dashboard.yml.j2
│  │  │  ├── traefik-helm-values.yml.j2
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for installing [Traefik](https://github.com/traefik/traefik-helm-chart), a modern HTTP reverse proxy and load balancer.

### Synopsis

This role does the following:

1. Creates a namespace for the Traefik deployment.
2. Deploys the [Traefik Helm chart](https://github.com/traefik/traefik-helm-chart#installing) with values that specify:
   - the enabling of access logs
   - the enabling of a dedicated metrics service for use with Prometheus
   - the enabling of cross namespace references
3. Configures [HTTP-to-HTTPS redirect middleware](https://doc.traefik.io/traefik/middlewares/http/redirectscheme/)
4. Configures a Certificate and an [IngressRoute](https://doc.traefik.io/traefik/providers/kubernetes-crd/) to the [Traefik Dashboard](https://doc.traefik.io/traefik/operations/api/#configuration).

### Configuration
                
Configure the namespace for the Traefik deployment via the variable `k3s_traefik_namespace`:
```yaml
k3s_traefik_namespace: traefik-system
```

Configure whether to enable the Linkerd service mesh via the variable `k3s_enable_service_mesh`:
```yaml
k3s_enable_service_mesh: true
```

Configure the user and password for the BasicAuth middleware used to access the Traefik Dashboard:
```yaml
traefik_basic_auth_user: admin
traefik_basic_auth_passwd: passwd
```   

Configure the local domain for the Traefik Dashboard via the variable `traefik_dashboard`:
```yaml
traefik_dashboard: traefik.deskpi.localnet
```

Configure the public domain for the Traefik Dashboard via the variable `public_traefik_dashboard`:
```yaml
public_traefik_dashboard: traefik.deskpi.localnet
```

Configure whether to allow access to the Longhorn dashboard over the public network
```yaml
enable_public_traefik_dashboard: false      
```

The variable `k3s_ingress_external_ip` is used to specify the external IP address for the Traefik Ingress Controller:
```yaml  
k3s_ingress_external_ip: 192.168.1.100 
```
This is typically the first IP address in the MetalLB IP range.

The helm values for the Traefik deployment can be tweaked in the [`templates/traefik-helm-values.yml.j2`](templates/traefik-helm-values.yml.j2) file.

### Testing

After the role has been executed, you can verify the Traefik deployment by checking the pods in the `traefik-system` namespace:
```shell
kubectl get pods -n traefik-system
```
Expected output (example):
```shell
NAME                                      READY   STATUS    RESTARTS   AGE
traefik-7b9b6c6b8b-4z5zv                  1/1     Running   0          2m
```
You can also check for errors in the Traefik logs:
```shell
kubectl logs -n traefik-system traefik-7b9b6c6b8b-4z5zv
```

You can verify Traefik's ability to create ingress routes by creating a test deployment and service. Do this by running the `deploy-nginx-ingress.yml` test playbook in 
the [`tests`](tests/deploy-nginx-ingress.yml) directory:
```shell
ansible-playbook roles/traefik-install/tests/deploy-nginx-ingress.yml 
```

After the playbook has been executed, you can check the ingress routes created by Traefik:
```shell
kubectl get svc,ingress
```

Expected output (example):
```shell
NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/nginx-test       ClusterIP   10.43.22.10    <none>        80/TCP    5s

NAME                                           CLASS    HOSTS                ADDRESS         PORTS   AGE
ingress.networking.k8s.io/nginx-test-ingress   <none>   test.cluster.local   192.168.1.100   80      5s
```
The host is a subdomain of the `cluster_local_domain` variable (in the example assumed to be *deskpi.localnet*), and the IP address should correspond to the `k3s_ingress_external_ip`.

You can use `curl` to test the service:
```shell
while true; do curl -s http://test.deskpi.localnet | grep "Served by pod"; sleep 1; done
````

You should see output, similar to the example below:
```html    
<p>Served by pod: <span style="color:red">nginx-test-698664cb6b-k8qjp</span></p>
<p>Served by pod: <span style="color:red">nginx-test-698664cb6b-j54zg</span></p>
<p>Served by pod: <span style="color:red">nginx-test-698664cb6b-tjqg5</span></p>
```

Clean up the testing resources by running the `cleanup.yml` test playbook in the [`tests`](tests/cleanup.yml) directory:
```shell
ansible-playbook roles/traefik-install/tests/cleanup.yml
```
                                                                                                     
### Accessing the Traefik Dashboard

The Traefik dashboard is exposed via an [IngressRoute](templates/traefik-dashboard.yml.j2) resource. 
You can access the dashboard by navigating to the domain specified in the `traefik_dashboard` variable and appending the `/dashboard/` path:
```shell
https://traefik.deskpi.localnet/dashboard/
```
Note the trailing slash ('/') in the URL.    

### References

- https://github.com/traefik/traefik-helm-chart#installing
- https://picluster.ricsanfre.com/docs/traefik/