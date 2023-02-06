# DeskPI Super6c

### Useful Links
- https://github.com/DeskPi-Team/super6c
- https://github.com/geerlingguy/deskpi-super6c-cluster
- https://www.jeffgeerling.com/blog/2020/raspberry-pi-cluster-episode-2-setting-cluster
- https://learn.networkchuck.com/courses/take/ad-free-youtube-videos/lessons/26093614-i-built-a-raspberry-pi-super-computer-ft-kubernetes-k3s-cluster-w-rancher
- https://www.the-diy-life.com/raspberry-pi-cm4-cluster-running-kubernetes-turing-pi-2/

## Step 1: Assemble the Board

## Step 2: Install the OS
We are going to install Raspberry Pi OS to the CM4's using the [Raspberry Pi Imager](https://www.raspberrypi.com/software/)

### eMMC 

The DeskPi functions as an IO Board and has micro-usb connectors next to each Compute Module. 
Note that CM1's usb connector is on the back of the [board](https://github.com/DeskPi-Team/super6c/blob/main/assets/port_definitions.png).

1. Install or compile [`rpiboot`](https://github.com/raspberrypi/usbboot) for your host OS. A windows installer is available here https://github.com/raspberrypi/usbboot/tree/master/win32. 
2. Download and Install the [Raspberry PI Imager](https://www.raspberrypi.com/software/) for your host OS.
3. Bridge the [`nRPBOOT`](https://github.com/DeskPi-Team/super6c/blob/main/assets/CM4_Jumpers.png)  jumper next to the CM you want to flash.
4. Plug in the Micro USB cable to the USB Connector of the CM you want to flash. 
5. Apply power to the board
6. Start `rpiboot`
7. After `rpiboot` completes you should  have access to a new mass storage device. Do not format if prompted.
8. Start the Raspberry Pi Imager tool.
9. Select your preferred OS (for k3s you need a **64-bit** OS). Typically, the 64-bit lite version should be sufficient, unless you want full GUI support.
10. Select the newly discovered raspberry mass storage device to write to.
11. NOTE: In `Advanced options`, be sure to 
	* set the **hostname** of your Pi to something unique and memorable (I chose `deskpi` followed by a number, e.g. `deskpi1`)  
	* enable **passwordless** SSH 
	* set a common **username** for all your Pi's (I chose `deskpi`), as well as an optional password. 
	* configure Wireless LAN, if it is supported by your CM (optional)
12. Repeat this for all CMs - the headless CM's do not need a desktop environment, so the 64-bit lite version of Raspberry Pi OS should be sufficient. Remember to change the hostname for every CM.

### Notes
1. You may need to enable USB2.0 support for the CM in the first slot by adding `dtoverlay=dwc2,dr_mode=host` to the `config.txt` file in the root of the boot image.
2. If you did not enable SSH via the Imager, to enable it you can create a blank file called `ssh` in the root of the boot image.
3. At least on my monitor, I did not get a video signal, so for the CM in the first slot I had to replace `dtoverlay=vc4-kms-v3d`with `dtoverlay=vc4-fkms-v3d` (note the additional "f") in the `config.txt` file. I figured this out from this [comment](https://forums.raspberrypi.com/viewtopic.php?t=323920#p1939139) on the raspberry forums.
4. You **cannot** mount an [SD Card to a CM with eMMC](https://www.reddit.com/r/retroflag_gpi/comments/snesyy/is_it_impossible_to_mount_the_sd_card_with_an/). Even though it's not explicitly stated, and the documentation on the Super6c github misleadingly states in the [TroubleShooting Section](https://github.com/DeskPi-Team/super6c#troubleshooting) that
	> "If your CM4 module has eMMC on board, the SSD drive and **TF card** can be external mass storage." 
	
#### References
- https://github.com/raspberrypi/usbboot
- https://www.raspberrypi.com/documentation/computers/compute-module.html#flashing-the-compute-module-emmc
- https://www.jeffgeerling.com/blog/2020/usb-20-ports-not-working-on-compute-module-4-check-your-overlays

### Non-eMMC (CM4 Lite)
Flash Raspberry Pi OS to the TF cards or SSD drives, insert them into the card slot, fix it with screws, connect the power supply, and press `PWR_BTN` button to power them on.

## Step 3: Prepare the cluster

### Installation requirements

- python (>= v3.6)
- PyYAML (>= v3.11)
- Ansible (>= v2.13) For detailed instructions on installing Ansible see the [Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
- The [Kubernetes modules](https://docs.ansible.com/ansible/latest/collections/kubernetes/core/docsite/kubernetes_scenarios/k8s_intro.html) for Ansible. To install it you can run: `ansible-galaxy collection install kubernetes.core`
- The [Kubernetes Python client](https://pypi.org/project/kubernetes/) (>= v25.0.0) Installed on the host that will execute the modules.

Furthermore, you will also need the `kubernetes-validate` python library. You can install this with [PyPi](https://pypi.org/project/kubernetes-validate/): `pip install kubernetes-validate`

### Check the configuration of the cluster  

1. Update the [`hosts.ini`](hosts.ini) file
   - with the hostnames of the Pi's in your cluster
   - set the IP address octets (the last group of numbers in the IP address) to a range that is unoccupied in your network
   - set `ansible_user` to the username you defined for your Pi's during [Step 2](#step-3-prepare-the-cluster)  
2. In the [`config.yml`](playbooks/vars/config.yml) 
   - set `ip_subnet_prefix` to the IP subnet prefix of your network
   - set `gateway` to the IP address of the gateway in your network
	                                                            
For example, if `ip_subnet_prefix` in the `config.yml` is defined as follows:
```yaml
ip_subnet_prefix: 192.168.1   
```
and the `hosts.ini` has the following content:
```ini
[control_plane]
deskpi1 ip_octet=200

[nodes]
deskpi2 ip_octet=201
deskpi3 ip_octet=202
deskpi4 ip_octet=203
deskpi5 ip_octet=204
deskpi6 ip_octet=205
```
Then the server / master node has the hostname `deskpi1` and the ip address: `192.168.1.200` and the last node in the cluster has the hostname `deskpi6` and ip address `192.168.1.205`.

### Execute the Preparation Playbook

Run the [prepare.yml](playbooks/prepare.yml) playbook

```bash
ansible-playbook playbooks/prepare.yml
```

This playbook will, on every Pi:
 - Enable cpu and memory control groups 
 - Configure a static ip (with the ip-address configured in `hosts.ini`)
 - Add required software dependencies
 - Update all software packages
 - Switch to legacy ip-tables (if required)
 - Copy the `.*rc` files in the `resources` folder
 - Reboot the Pi

The reboot task may time out if the ip addresses of the Pi's were changed during the playbook run. 
Consequently, you may have to flush your dns cache before you will be able to connect to them again. 

## Step 4: Build the Cluster
                                                                                  
### Installing [k3s](https://k3s.io/)

After running the preparation playbook it's time to install [k3s](https://k3s.io/).

1. Run the [k3s-install.yml](playbooks/k3s-install.yml) playbook
	```bash
	ansible-playbook playbooks/k3s-install.yml
	```
2. Once the play completes you can check whether the cluster was successfully installed by logging into the master node and running `kubectl get nodes`.
   You should see something like the following:
	```bash   
	deskpi@deskpi1:~ $ kubectl get nodes
	NAME    STATUS   ROLES                  AGE VERSION
	deskpi1 Ready    control-plane,master   33s v1.25.4+k3s1
	deskpi4 Ready    <none>                 32s v1.25.4+k3s1
	deskpi5 Ready    <none>                 32s v1.25.4+k3s1
	deskpi2 Ready    <none>                 32s v1.25.4+k3s1
	deskpi6 Ready    <none>                 32s v1.25.4+k3s1
	deskpi3 Ready    <none>                 32s v1.25.4+k3s1
	```
If something went wrong during the installation you can check the installation log, which is saved to a file called `k3s_install_log.txt` in the home directory of root.

```bash
deskpi@deskpi1:~ $ sudo -i
root@deskpi1:~ # cat k3s_install_log.txt

[INFO]  Finding release for channel stable
[INFO]  Using v1.25.4+k3s1 as release
[INFO]  Downloading hash https://github.com/k3s-io/k3s/releases/download/v1.25.4+k3s1/sha256sum-arm64.txt
[INFO]  Downloading binary https://github.com/k3s-io/k3s/releases/download/v1.25.4+k3s1/k3s-arm64
[INFO]  Verifying binary download
[INFO]  Installing k3s to /usr/local/bin/k3s
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

### Uninstalling k3s

You can uninstall k3s by running the [`k3s-uninstall.yml`](playbooks/k3s-uninstall.yml) playbook:

```bash
ansible-playbook playbooks/k3s-uninstall.yml
```

## Step 5: Run Post Ops after k3s Install

After k3s has been successfully set up on your cluster, you should run the post-install playbook:

```bash
ansible-playbook playbooks/k3s-post-install.yml
```
                                                                   
- [`kubectl`](https://kubernetes.io/docs/reference/kubectl/) is automatically installed by the k3s installation
script - [kubectl autocompletion](https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/) and the alias `kc` is enabled by this playbook.

- [Traefik](https://traefik.io/) is the default Ingress Controller installed for kubernetes by k3s, this playbook creates an Ingress Route to the [Traefik Dashboard](https://doc.traefik.io/traefik/operations/dashboard/) and exposes the dashboard at `<your-deskpi-ip>/dashboard/`.
- [Helm](https://helm.sh/) the package manager for kubernetes, and we will use it to install other packages.
- An [NFS Storage Class](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) based on an NFS export created on the `control_plane` host.

These playbooks are tagged and can be played individually via the `--tags` argument for `ansible-playbook`
 
For example, to install specifically only **Helm** you can run the playbook as follows:
```bash
ansible-playbook playbooks/k3s-post-install.yml --tags "helm" 
```

## Step 6: Install additional Packages

Packages for k3s are declared in the playbook [`k3s-packages.yml`](playbooks/k3s-packages.yml), they are tagged and can be played individually via the `--tags` argument for `ansible-playbook`.

### [Prometheus](https://prometheus.io/)
                 
#### About
Prometheus is an open-source systems monitoring and alerting toolkit. We’ll use Helm to install the [Kube-Prometheus stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) into our K3s cluster.

The Kube-Prometheus stack typically installs the following components:

- [Prometheus](https://prometheus.io/)
- [Alert-manager](https://github.com/prometheus/alertmanager) (though **disabled** in our playbook)
- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)
- [Prometheus Node Exporter](https://github.com/prometheus/node_exporter)
- [Prometheus Adapter for Kubernetes Metrics APIs](https://github.com/kubernetes-sigs/prometheus-adapter)
- [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)
- [Grafana](https://grafana.com/)

Helm and Kube-Prometheus pre-configure these components to scrape several endpoints in our cluster by default.

Such as, among others, the 
- `cadvisor` 
- `kubelet` 
- node-exporter `/metrics` endpoints on K8s Nodes, 
- K8s API server metrics endpoint 
- kube-state-metrics endpoints 

To see a full list of configured scrape targets, refer to the Kube-Prometheus Helm chart’s [values.yaml](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml).
You can find scrape targets by searching for `serviceMonitor` objects. To learn more about configuring the Kube-Prometheus stack’s scrape targets, see the `ServiceMonitor` spec in the [Prometheus Operator GitHub repo](https://github.com/prometheus-operator/prometheus-operator).

The Kube-Prometheus stack also provisions several monitoring [mixins](https://github.com/monitoring-mixins/docs). A 'mixin' is a collection of prebuilt Grafana dashboards, Prometheus recording rules, and Prometheus alerting rules. 

In particular, it includes:

- The [Kubernetes Mixin](https://github.com/kubernetes-monitoring/kubernetes-mixin), which includes several useful dashboards and alerts for monitoring K8s clusters and their workloads
- The [Node Mixin](https://github.com/prometheus/node_exporter/tree/master/docs/node-mixin), which does the same for 'Node Exporter' metrics
- The [Prometheus Mixin](https://github.com/prometheus/prometheus/tree/main/documentation/prometheus-mixin)

Mixins are written in [Jsonnet](https://jsonnet.org/), a data templating language, and generate JSON dashboard files and rules YAML files. 

To learn more, check out 

- [Generate config files](https://github.com/monitoring-mixins/docs#generate-config-files) (from the Prometheus Monitoring Mixins repo)
- [Grizzly](https://github.com/grafana/grizzly)  (a tool for working with Jsonnet-defined assets against the Grafana Cloud API)

#### Installation

To install specifically only the Kube-Prometheus stack you can run the playbook with the a `--tags` argument:

```bash
ansible-playbook playbooks/k3s-packages.yml --tags "prometheus" 
```
                                                               
A precondition is that **Helm** has already been installed. 

### [Rook-Ceph](https://rook.io/)

[Rook](https://rook.io/) is a specialized Storage Operator for Kubernetes and orchestrates a [Ceph](https://ceph.io/en/) Storage cluster solution. 

With Ceph we can expose the NVMe SSD's installed on our DeskPi Super6c as a shared Filesystem (CephFS) on which we can mount an NFS.   

Before installing Rook and Ceph ensure that the drives you wish to include in the Ceph cluster do not have formatted filesystems.

You can check that by executing the command `lsblk -f` and verifying that the `FSTYPE` field is empty on those devices you wish to have included in the Ceph cluster. 
			  
```bash
$ lsblk -f
NAME         FSTYPE FSVER LABEL  UUID                                 FSAVAIL FSUSE% MOUNTPOINT
mmcblk0
├─mmcblk0p1  vfat   FAT32 boot   3772-58CD                             224.5M    12% /boot
└─mmcblk0p2  ext4   1.0   rootfs ee7f279a-1fe9-4c98-9f3c-83c7173683b7     23G    14% /
nvme0n1
```
In the example above, we can use `nvme0n1` for Ceph but not `mmcblk0` or any of its partitions. 
                 

### Additional Notes

#### Playbook to update software packages

You can run the [update](playbooks/update.yml) playbook to update all software packages on all the nodes configured in your deskPi cluster.

```bash
ansible-playbook playbooks/update.yml
```
