# [Ansible Playbooks](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html)

```
├── playbooks
│ ├── tasks
| |  ├── reboot.yml
│ ├── vars
| |  ├── config.yml
| ├── k3s-pre-install.yml
| ├── k3s-install.yml
| ├── k3s-post-install.yml
| ├── k3s-uninstall.yml
| ├── k3s-packages-install.yml
| ├── k3s-packages-uninstall.yml
| ├── update-deskpis.yml
| ├── reboot-deskpis.yml
| ├── shutdown-deskpis.yml
```
This structure houses the [Ansible Playbooks](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html) for my [DeskPi Super6c Cluster Homelab](https://github.com/louispool/deskpi-super6c).

Before running these playbooks, ensure that the

- the hosts have been properly configured in [inventory/hosts.yml](../inventory/hosts.yml),
- the [cluster variables](../inventory/group_vars/cluster.yml) are correct, and
- the [cluster configuration](./vars/config.yml) is up-to-date.

## Playbooks

### [k3s-pre-install](k3s-pre-install.yml)

This playbook prepares the cluster for k3s installation.   
                                                   
From the **project root directory**, run:
```bash
ansible-playbook playbooks/k3s-pre-install.yml
```
                
#### Synopsis

This playbook will, on every host in the cluster:

- Execute the [Cluster Preparation](../roles/cluster-prep/README.md) role
- Configure an [NTP Client](../roles/chrony/README.md)  
     
On the Control Plane / Master Node this playbook will also:
- Configure an [NTP Server](../roles/chrony/README.md)  
- Set up a [DNS Server](../roles/dnsmasq/README.md) 


### [k3s-install](k3s-install.yml)

This playbook installs the [k3s](https://k3s.io/) cluster. 

#### Configuration
               
The cluster configuration is largely contained within [config.yml](vars/config.yml) and consists of the following items:

* A kubelet configuration that enables [Graceful Node Shutdown](https://kubernetes.io/blog/2021/04/21/graceful-node-shutdown-beta/)
* Extra arguments for the k3s server installation (i.e. Control Plane / Master Node):
  - `--write-kubeconfig-mode '0644'` gives read permissions to Kube Config file (located at /etc/rancher/k3s/k3s.yaml)
  - `--disable servicelb` disables the default service load balancer installed by k3s (i.e. Klipper Load Balancer), instead we'll install MetalLB in a later step.
  - `--disable traefik` disables the default ingress controller installed by k3s (i.e. Traefik), instead we'll install Traefik ourselves in a later step. 
  - `--kubelet-arg 'config=/etc/rancher/k3s/kubelet.config'` points to the kubelet configuration (see above).
  - `--kube-scheduler-arg 'bind-address=0.0.0.0'` exposes the 0.0.0.0 address endpoint on the Kube Scheduler for metrics scraping.
  - `--kube-proxy-arg 'metrics-bind-address=0.0.0.0'` exposes the 0.0.0.0 address endpoint on the Kube Proxy for metrics scraping.
  - `--kube-controller-manager-arg 'bind-address=0.0.0.0'` exposes the 0.0.0.0 address endpoint on the Kube Controller Manager for metrics scraping.
  - `--kube-controller-manager-arg 'terminated-pod-gc-threshold=10'` set a limit of 10 terminated pods that can exist before the [garbage collector starts deleting terminated pods](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-garbage-collection).
* Extra arguments for k3s agent installation (i.e. Worker Nodes)
  - `--node-label 'node_type=worker'`adds a custom label to the worker node.
  - `--kubelet-arg 'config=/etc/rancher/k3s/kubelet.config'` points to the kubelet configuration (see above).
  - `--kube-proxy-arg 'metrics-bind-address=0.0.0.0'` exposes the 0.0.0.0 address endpoint on the Kube Proxy for metrics scraping.

#### Installation

Run the [k3s-install.yml](k3s-install.yml) playbook from the **project root directory**:
```bash
ansible-playbook playbooks/k3s-install.yml
```
Once the play completes you can check whether the cluster was successfully installed by logging into the master node and running `kubectl get nodes`.
You should see something like the following:
```bash 
deskpi@deskpi1:~ $ kubectl get nodes
NAME      STATUS   ROLES                  AGE VERSION
deskpi1   Ready    control-plane,master   33s v1.25.6+k3s1
deskpi2   Ready    worker                 32s v1.25.6+k3s1
deskpi3   Ready    worker                 32s v1.25.6+k3s1
deskpi4   Ready    worker                 32s v1.25.6+k3s1
deskpi5   Ready    worker                 32s v1.25.6+k3s1
deskpi6   Ready    worker                 32s v1.25.6+k3s1
```

If something went wrong during the installation you can check the installation log, which is saved to a file called `k3s_install_log.txt` in the home directory of root.

```bash
deskpi@deskpi1:~ $ sudo -i
root@deskpi1:~# cat k3s_install_log.txt
[INFO]  Finding release for channel stable
[INFO]  Using v1.25.6+k3s1 as release
[INFO]  Downloading hash https://github.com/k3s-io/k3s/releases/download/v1.25.6+k3s1/sha256sum-arm64.txt
[INFO]  Downloading binary https://github.com/k3s-io/k3s/releases/download/v1.25.6+k3s1/k3s-arm64
[INFO]  Verifying binary download
[INFO]  Installing k3s to /usr/local/bin/k3s
[INFO]  Skipping installation of SELinux RPM
[INFO]  Creating /usr/local/bin/kubectl symlink to k3s
[INFO]  Creating /usr/local/bin/crictl symlink to k3s
[INFO]  Creating /usr/local/bin/ctr symlink to k3s
[INFO]  Creating killall script /usr/local/bin/k3s-killall.sh
[INFO]  Creating uninstall script /usr/local/bin/k3s-uninstall.sh
[INFO]  env: Creating environment file /etc/systemd/system/k3s.service.env
[INFO]  systemd: Creating service file /etc/systemd/system/k3s.service
[INFO]  systemd: Enabling k3s unit
[INFO]  systemd: Starting k3s
```

### [k3s-uninstall](k3s-uninstall.yml)

You can uninstall k3s by running the [`k3s-uninstall.yml`](k3s-uninstall.yml) playbook from the **project root**:

```bash
ansible-playbook playbooks/k3s-uninstall.yml
```

### [k3s-post-install](k3s-post-install.yml)

This playbook executes several operations and installs several packages after k3s has been successfully installed to the DeskPi cluster. 

 
#### Installation

After k3s has been successfully set up on your cluster, you can run the post-install playbook from the **project root**:

```bash
ansible-playbook playbooks/k3s-post-install.yml
```

#### Synopsis

This playbook does the following:   

- Configures [kubectl autocompletion](https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/) and the alias `kc` is created
  for [`kubectl`](https://kubernetes.io/docs/reference/kubectl/), which is automatically installed by the k3s installation script, on every host in the cluster.
- Installs [Helm](https://helm.sh/), the package manager for kubernetes, which will be used to install other k8s packages.
- Creates an [NFS Storage Class](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner), based on an NFS export, on the Control Plane.

These tasks are tagged and can be played individually via the `--tags` argument for `ansible-playbook`

For example, to install specifically only **Helm** you can run the playbook as follows:

```bash
ansible-playbook playbooks/k3s-post-install.yml --tags "helm" 
```

### [k3s-packages-install](k3s-packages-install.yml)

This playbook installs various additional packages to the k3s cluster.

#### Configuration

Certain packages are gated by specific flags in the [configuration](./vars/config.yml):

- `k3s_enable_service_mesh` Whether to install [Linkerd](https://linkerd.io/) and inject proxy annotations into deployments.
- `k3s_enable_block_storage` Whether to install [Longhorn](https://longhorn.io/).

Certain variables affect the configuration of some of the packages:

- `k3s_external_ip_range` The IP Address Pool used by the Load Balancer. In either CIDR notation (e.g. `192.168.10.0/24`) or a start and an end IP address separated by a hyphen (
  e.g. `192.168.9.1-192.168.9.5`)
- `k3s_ingress_external_ip` External IP for Kubernetes Ingress (used by Traefik).
- `tls_issuer` The TLS certificate issuer.
- `longhorn_storage_path` Path to mount the disk to (and subsequently used by Longhorn).
- `longhorn_disk_device` Name of the disk device to use.
- `longhorn_prepare_disk` Whether to allow wiping and formatting of the disk device.

#### Installation

Run the [k3s-packages-install.yml](k3s-packages-install.yml) playbook from the **project root directory**:

```bash
ansible-playbook playbooks/k3s-packages-install.yml
```

#### Synopsis

The playbook includes the roles:

- [Install MetalLB](../roles/metallb-install/README.md) (Load Balancer)
- [Install Cert-Manager](../roles/cert-manager-install/README.md) (Certificate Management)
- [Install Linkerd](../roles/linkerd-install/README.md) (Service Mesh)
- [Install Traefik](../roles/traefik-install/README.md) (Ingress Controller)
- [Install Longhorn](../roles/longhorn-install/README.md)  (Storage Controller)

Packages are tagged and can be played individually via the `--tags` argument for `ansible-playbook`

For example, to install specifically only **Traefik** you can run the playbook as follows:

```bash
ansible-playbook playbooks/k3s-packages-install.yml --tags "traefik" 
```

### [k3s-packages-uninstall](k3s-packages-uninstall.yml)

This playbook removes the additional packages added to the k3s cluster during [k3s-packages-install](#k3s-packages-install).

#### Installation

Run the [k3s-packages-uninstall.yml](k3s-packages-uninstall.yml) playbook from the **project root directory**:

```bash
ansible-playbook playbooks/k3s-packages-uninstall.yml
```

#### Synopsis

The playbook includes the roles:

- [Uninstall MetalLB](../roles/metallb-uninstall/README.md) (Load Balancer)
- [Uninstall Cert-Manager](../roles/cert-manager-uninstall/README.md) (Certificate Management)
- [Uninstall Linkerd](../roles/linkerd-uninstall/README.md) (Service Mesh)
- [Uninstall Traefik](../roles/traefik-uninstall/README.md) (Ingress Controller)
- [Uninstall Longhorn](../roles/longhorn-uninstall/README.md)  (Storage Controller)

Packages are tagged and can be played individually via the `--tags` argument for `ansible-playbook`

For example, to uninstall specifically only **Traefik** you can run the playbook as follows:

```bash
ansible-playbook playbooks/k3s-packages-uninstall.yml --tags "traefik" 
```

## Additional Playbooks

### [update-deskpis.yml](update-deskpis.yml)

Updates the software on all the Pi's in the cluster. Reboots them if required.

```bash
ansible-playbook playbooks/update-deskpis.yml
```
(Run from the project root directory)

### [reboot-deskpis.yml](reboot-deskpis.yml)

Reboots all the Pi's in the cluster.

```bash
ansible-playbook playbooks/reboot-deskpis.yml
```
(Run from the project root directory)

### [shutdown-deskpis.yml](shutdown-deskpis.yml)

Shuts down all the Pi's in the cluster.

```bash
ansible-playbook playbooks/shutdown-deskpis.yml
```
(Run from the project root directory)