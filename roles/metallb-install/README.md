# Role definition for installing [MetalLB](https://metallb.universe.tf/).

```
├── roles
│  ├── metallb-install
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── tasks 
|  |  |  ├── main.yml  
|  |  ├── templates
|  |  |  ├── metallb-config.yml.j2
```

[Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) definition for installing [*MetalLB*](https://metallb.universe.tf/installation/), a load-balancer implementation for bare metal Kubernetes clusters.

We will use MetalLB in [Layer-2 mode](https://metallb.universe.tf/concepts/layer2/).

> In layer 2 mode, one node assumes the responsibility of advertising a service to the local network. From the network’s perspective, it simply looks like that machine has multiple IP addresses
assigned to its network interface.
>
> All traffic for a service IP goes to one node. From there, kube-proxy spreads the traffic to all the service’s pods.
>
> In that sense, layer 2 does not implement a load balancer. Rather, it implements a failover mechanism so that a different node can take over should the current leader node fail for some reason.
            
### Synopsis

This role does the following: 

1. Creates a namespace for the MetalLB deployment.
2. Deploys the [MetalLB Helm chart](https://metallb.universe.tf/installation/#installation-with-helm).
3. Configures the CRD's:
   - [IPAddressPool](https://metallb.universe.tf/configuration/#defining-the-ips-to-assign-to-the-load-balancer-services)
   - [L2Advertisement](https://metallb.universe.tf/configuration/#layer-2-configuration)

### Configuration

Configure the namespace for the MetalLB deployment via the config variable `k3s_metallb_namespace`:
```
k3s_metallb_namespace: metallb-system
```

Configure the pool of IP addresses MetalLB can assign to services via the variable `k3s_external_ip_range`. 
In either CIDR notation (e.g. 192.168.10.0/24) or as a start and an end IP address separated by a hyphen:
```yaml
k3s_external_ip_range="192.168.1.100-192.168.1.200"
```

### Testing

After the role has been executed, you can verify that MetalLB is assigning ip addresses and load balancing properly by deploying a LoadBalancer service for NGINX 
via the `deploy-nginx.yml` test playbook in the [`tests`](tests/deploy-nginx.yml) directory.
                                                                           
From the project root directory, run the following command:
```shell
ansible-playbook roles/metallb-install/tests/deploy-nginx.yml 
```

On the cluster, verify that MetalLB assigned an external IP:
```shell
kubectl get svc nginx-test-lb
```

You should see an external IP assigned to the load balancer service:
```
NAME            TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
nginx-test-lb   LoadBalancer   10.43.0.100    192.168.1.101 80:31912/TCP   1m
```

You can use `curl` in a loop to hit the service:
```shell                                       
while true; do curl -s http://192.168.1.101 | grep "Served by pod"; sleep 1; done
```

You should see output, similar to the example below, demonstrating load balancing between the pods:                                          
```shell    
<p>Served by pod: <span style="color:red">nginx-test-698664cb6b-k8qjp</span></p>
<p>Served by pod: <span style="color:red">nginx-test-698664cb6b-j54zg</span></p>
<p>Served by pod: <span style="color:red">nginx-test-698664cb6b-tjqg5</span></p>
```

Clean up the testing resources by running the `cleanup.yml` test playbook in the [`tests`](tests/cleanup.yml) directory:
```shell
ansible-playbook roles/metallb-install/tests/cleanup.yml
```

### References

https://metallb.universe.tf/installation/
https://picluster.ricsanfre.com/docs/metallb/
