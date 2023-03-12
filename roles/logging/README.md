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

[Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) definition for installing [*MetalLB*](https://metallb.universe.tf/installation/), a
load-balancer implementation for bare metal Kubernetes clusters.

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

### References

https://metallb.universe.tf/installation/
