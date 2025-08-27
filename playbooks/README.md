# Ansible Playbooks


>`├── playbooks`<br>
>`│ ├── tasks`<br>
>`│ │  ├── reboot.yml`<br>
>`│ ├── vars`<br>
>`│ │  ├── `[`README.md`](vars/README.md)<br>
>`│ │  ├── config.yml`<br>
>`│ │  ├── vault.yml`<br>
>`│ ├── k3s-pre-install.yml`<br>
>`│ ├── k3s-install.yml`<br>
>`│ ├── k3s-post-install.yml`<br>
>`│ ├── k3s-uninstall.yml`<br>
>`│ ├── k3s-packages-install.yml`<br>
>`│ ├── k3s-packages-uninstall.yml`<br>
>`│ ├── update-deskpis.yml`<br>
>`│ ├── reboot-deskpis.yml`<br>
>`│ ├── shutdown-deskpis.yml`<br>
>`│ ├── update-route53-ddns.yml`<br>

This structure houses the Ansible Playbooks.

## [k3s-pre-install](k3s-pre-install.yml)

This playbook prepares the cluster for K3s installation.   
                
### Synopsis

This playbook will, on every host in the cluster:

- Execute the [Cluster Preparation](../roles/cluster-pre-install/README.md) role
- Configure an [NTP Client](../roles/chrony/README.md)  
     
On the Control Plane / Master Node this playbook will also:
- Configure an [NTP Server](../roles/chrony/README.md)  
- Set up a [DNS Server](../roles/dnsmasq/README.md) 
  
### Installation

From the **project root directory**, run:
```shell
ansible-playbook playbooks/k3s-pre-install.yml
```
The playbook uses tags to allow you to run only specific tasks. For example, to run only the task that installs the DNS Server to the control plane, you can run the playbook as follows:
```shell
ansible-playbook playbooks/k3s-pre-install.yml --limit control_plane --tags "dns"
```

## [k3s-install](k3s-install.yml)

This playbook installs the [K3s](https://k3s.io/) cluster. 

### Configuration
               
The cluster configuration is largely contained within [config.yml](vars/config.yml) and consists of the following items:

* A kubelet configuration that enables [Graceful Node Shutdown](https://kubernetes.io/blog/2021/04/21/graceful-node-shutdown-beta/)
* Extra arguments for the K3s server installation (i.e. Control Plane / Master Node):
  - `--write-kubeconfig-mode '0644'` gives read permissions to Kube Config file (located at /etc/rancher/k3s/k3s.yaml)
  - `--disable servicelb` disables the default service load balancer installed by K3s (i.e. Klipper Load Balancer), instead we'll install MetalLB in a later step.
  - `--disable traefik` disables the default ingress controller installed by K3s (i.e. Traefik), instead we'll install Traefik ourselves in a later step. 
  - `--kubelet-arg 'config=/etc/rancher/k3s/kubelet.config'` points to the kubelet configuration (see above).
  - `--kube-scheduler-arg 'bind-address=0.0.0.0'` exposes the 0.0.0.0 address endpoint on the Kube Scheduler for metrics scraping.
  - `--kube-proxy-arg 'metrics-bind-address=0.0.0.0'` exposes the 0.0.0.0 address endpoint on the Kube Proxy for metrics scraping.
  - `--kube-controller-manager-arg 'bind-address=0.0.0.0'` exposes the 0.0.0.0 address endpoint on the Kube Controller Manager for metrics scraping.
  - `--kube-controller-manager-arg 'terminated-pod-gc-threshold=10'` set a limit of 10 terminated pods that can exist before the [garbage collector starts deleting terminated pods](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-garbage-collection).
* Extra arguments for K3s agent installation (i.e. Worker Nodes)
  - `--node-label 'node_type=worker'`adds a custom label to the worker node.
  - `--kubelet-arg 'config=/etc/rancher/k3s/kubelet.config'` points to the kubelet configuration (see above).
  - `--kube-proxy-arg 'metrics-bind-address=0.0.0.0'` exposes the 0.0.0.0 address endpoint on the Kube Proxy for metrics scraping.

### Installation

Run the [k3s-install.yml](playbooks/k3s-install.yml) playbook from the **project root directory**:
```bash
ansible-playbook playbooks/k3s-install.yml
```

Once the play completes you can check whether the cluster was successfully installed by ssh'omg into the master node and running `kubectl get nodes`.
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

## [k3s-uninstall](k3s-uninstall.yml)

You can uninstall K3s by running the [`k3s-uninstall.yml`](playbooks/k3s-uninstall.yml) playbook from the **project root**:
```bash
ansible-playbook playbooks/k3s-uninstall.yml
```

## [k3s-post-install](k3s-post-install.yml)

This playbook executes several operations and installs several packages after K3s has been successfully installed to the deskpi cluster. 

### Synopsis

This playbook does the following:   

- Configures [kubectl autocompletion](https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/) and creates the alias `kc` for [`kubectl`](https://kubernetes.io/docs/reference/kubectl/), which is automatically installed by the K3s installation script, on every host in the cluster.
- Installs [Helm](https://helm.sh/), the package manager for kubernetes, which will be used to install other k8s packages.
- Creates an [NFS Storage Class](../roles/nfs-storage/README.md), based on an NFS export, on the Control Plane.
- Updates [CoreDNS](https://docs.k3s.io/networking/networking-services#coredns) to use a replica count of 2 (required by Longhorn) and forward DNS requests to public DNS servers (needed for Let's Encrypt to work).

### Configuration

Configuration variables can be found in the [vars/config.yml](vars/config.yml).

To configure the host as a local NFS Server, set the variable:
```
local_nfs_server: true
```
Alternatively, to set the location of a **remote** NFS Server; set the variables:
```
local_nfs_server: false
nfs_server: <ip_address_of_nfs>
```
In both cases ensure the path to the share is correct:
```
nfs_path: <path_to_share>
```

### Installation

After K3s has been successfully set up on your cluster, you can run the post-install playbook from the **project root**:

```bash
ansible-playbook playbooks/k3s-post-install.yml
```

The tasks are tagged and can be played individually via the `--tags` argument for `ansible-playbook`

For example, to install specifically only **Helm** you can run the playbook as follows:

```bash
ansible-playbook playbooks/k3s-post-install.yml --tags "helm" 
```
     
## [k3s-packages-install](k3s-packages-install.yml)

Installs several packages to K3s:

| Package                                                                   | Purpose                  | Tag                                 |
|:--------------------------------------------------------------------------|:-------------------------|:------------------------------------|
| [MetalLB](../roles/metallb-install/README.md)                             | Load Balancer            | `metallb`                           |
| [Cert-Manager](../roles/cert-manager-install/README.md)                   | Certificate Management   | `certmanager`                       |
| [Route53-ddns](../roles/route53-ddns-install/README.md)                   | Dynamic DNS for Route53  | `certmanager`, `route53ddns`        |
| [Traefik](../roles/traefik-install/README.md)                             | Ingress Controller       | `traefik`                           |
| [Longhorn](../roles/longhorn-install/README.md)                           | Block Storage Controller | `longhorn`                          |
| [Prometheus](../roles/prometheus-install/README.md)                       | Monitoring and Alerting  | `prometheus`, `monitoring`          |
| [Prometheus Post-Install](../roles/prometheus-post-install/README.md)     | Monitoring and Alerting  | `prometheus-post`, `monitoring`     |
| [RPI Metrics Exporter](../roles/rpi-metrics-exporter/README.md)           | Hardware Telemetry       | `rpi-metrics`, `monitoring`         |
| [OpenSearch](../roles/opensearch-install/README.md)                       | Search and Analytics     | `opensearch`, `logstack`            |
| [OpenSearch Dashboards](../roles/opensearch-dashboards-install/README.md) | Search and Analytics     | `opensearch-dashboards`, `logstack` |
| [Fluentbit](../roles/opensearch-install/README.md)                        | Logs scraping            | `fluentbit`, `logstack`             |
| [Linkerd](../roles/linkerd-install/README.md)                             | Service Mesh             | `linkerd`                           |

### Installation

```bash
ansible-playbook playbooks/k3s-packages-install.yml 
```

Packages can be individually installed with the corresponding `tag`, for example:
```bash
ansible-playbook playbooks/k3s-packages-install.yml --tags "metallb,certmanager,traefik" 
```

## [k3s-packages-uninstall](k3s-packages-uninstall.yml)

Removes packages installed to K3s: 

| Package                                                                         | Tag(s)                       |
|:--------------------------------------------------------------------------------|:-----------------------------|
| [MetalLB](../roles/metallb-uninstall/README.md)                                 | `metallb`                    |
| [Cert-Manager](../roles/cert-manager-uninstall/README.md)                       | `certmanager`                |
| [Route53-DDNS](../roles/route53-ddns-uninstall/README.md)                       | `certmanager`, `route53ddns` |
| [Traefik](../roles/traefik-uninstall/README.md)                                 | `traefik`                    |
| [Longhorn](../roles/longhorn-uninstall/README.md)                               | `longhorn`                   |
| [Prometheus](../roles/prometheus-uninstall/README.md)                           | `prometheus`                 |
| [OpenSearch](../roles/opensearch-uninstall/README.md)[^1]                       | `opensearch`, `logstack`     |
| [OpenSearch Dashboards](../roles/opensearch-dashboards-uninstall/README.md)[^2] | `opensearch-dashboards`      |
| [Fluentbit](../roles/fluentbit-uninstall/README.md)                             | `fluentbit`, `logstack`      |
| [Linkerd](../roles/linkerd-uninstall/README.md)                                 | `linkerd`                    |

[^1]: Also uninstalls OpenSearch Dashboards

[^2]: Only uninstalls OpenSearch Dashboards not OpenSearch

```bash
ansible-playbook playbooks/k3s-packages-uninstall.yml 
```

Packages can be individually uninstalled with the corresponding `tag`, for example:
```bash
ansible-playbook playbooks/k3s-packages-uninstall.yml --tags "metallb,certmanager,traefik" 
```

## Additional Playbooks

### [update-deskpis.yml](update-deskpis.yml)

Updates the software on all the CMs in the cluster. Reboots them if required.

```bash
ansible-playbook playbooks/update-deskpis.yml
```
(Run from the project root directory)

### [reboot-deskpis.yml](reboot-deskpis.yml)

Reboots all the CMs in the cluster.

```bash
ansible-playbook playbooks/reboot-deskpis.yml
```
(Run from the project root directory)

### [shutdown-deskpis.yml](shutdown-deskpis.yml)

Shuts down all the CMs in the cluster.

```bash
ansible-playbook playbooks/shutdown-deskpis.yml
```
(Run from the project root directory)
          
### [update-route53-ddns.yml](update-route53-ddns.yml)

Updates the DDNS records for the CMs in the cluster using the [Route53 DDNS script](../roles/route53-ddns-install/README.md).

```bash
ansible-playbook playbooks/update-route53-ddns.yml
```
(Run from the project root directory)

