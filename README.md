# DeskPI Super6c

### Useful Links
- [DeskPi Super6c](https://github.com/DeskPi-Team/super6c)
- [Ricsanfre's Pi Cluster](https://picluster.ricsanfre.com/)
- [rpi4cluster.com](https://rpi4cluster.com/)
- [Jeff Geerling's DeskPi Super6c Cluster](https://github.com/geerlingguy/deskpi-super6c-cluster)
- [Jeff Geerling's Raspberry Pi Cluster Ep. 2](https://www.jeffgeerling.com/blog/2020/raspberry-pi-cluster-episode-2-setting-cluster)
- [Network Chuck's Raspberry Pi k3s Cluster](https://learn.networkchuck.com/courses/take/ad-free-youtube-videos/lessons/26093614-i-built-a-raspberry-pi-super-computer-ft-kubernetes-k3s-cluster-w-rancher)
- [The DIY Life: Turing Pi 2 Cluster](https://www.the-diy-life.com/raspberry-pi-cm4-cluster-running-kubernetes-turing-pi-2/)


# 1. Board Assembly

Assembly is described on the DeskPi Super6c's [github page](https://github.com/DeskPi-Team/super6c#how-to-assemble).

# 2. OS Installation
                     
There are several ways we can install the OS to the Compute Modules (CM4) on the DeskPi Super6c, depending on whether the CM4 has eMMC storage or not.
For the most part, we will be using the [Raspberry Pi Imager](https://www.raspberrypi.com/software/) tool to flash the OS to the CM4's.

Take note that [K3s](https://docs.k3s.io/) requires a 64-bit OS. Additionally, some storage solutions, such as [Rook Ceph](https://rook.io/), require a Linux distribution shipped 
with the `lvm2` package, which is not included in the Raspberry Pi OS distributions. 

Furthermore, [K3s](https://docs.k3s.io/installation/requirements?os=pi) recommends installing to an SSD for performance reasons; since `etcd` is write-intensive 
and, typically, SD cards and eMMC cannot handle the I/O load.

Therefore, I recommend installing the [Ubuntu Server 64-bit](https://ubuntu.com/download/raspberry-pi) distribution to an NVMe SSD using [Method 3](#method-3-installing-the-os-to-the-nvme-ssd) below.

## Method 1: eMMC 

The DeskPi functions as an IO Board and has micro-usb connectors next to each Compute Module. 
Note that **CM4#1**'s usb connector is on the back of the [board  where the IO ports are located](https://github.com/DeskPi-Team/super6c/blob/main/assets/port_definitions.png).

1. Install or compile [`rpiboot`](https://github.com/raspberrypi/usbboot) for your host OS. A Windows installer is available here https://github.com/raspberrypi/usbboot/tree/master/win32. 
2. Download and install the [Raspberry PI Imager](https://www.raspberrypi.com/software/) for your host OS.
3. Bridge the [`nRPBOOT`](https://github.com/DeskPi-Team/super6c/blob/main/assets/CM4_Jumpers.png)  jumper next to the CM you want to flash.
4. Plug in the Micro USB cable to the USB Connector of the CM you want to flash. 
5. Apply power to the board
6. Start `rpiboot`
7. After `rpiboot` completes you should  have access to a new mass storage device. Do not format if prompted.
8. Start the Raspberry Pi Imager tool.
9. Select your preferred OS (for k3s you need a **64-bit** OS). 
   Typically, the 64-bit lite version should be sufficient, unless you want full GUI support - which would only make sense for the CM in the first slot.
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
3. When `ssh`'ing into the CM's, recall the user that you set during installation, in my case the `ssh` command would be something like: `ssh deskpi@deskpi1`
4. At least on my monitor, I did not get a video signal, so for the CM in the first slot I had to replace `dtoverlay=vc4-kms-v3d`with `dtoverlay=vc4-fkms-v3d` (note the additional "f") in the `config.txt` file. I figured this out from this [comment](https://forums.raspberrypi.com/viewtopic.php?t=323920#p1939139) on the raspberry forums.
5. Even though it's not explicitly stated, and the documentation on the Super6c github misleadingly states in the [TroubleShooting Section](https://github.com/DeskPi-Team/super6c#troubleshooting) that
	> "If your CM4 module has eMMC on board, the SSD drive and **TF card** can be external mass storage."
   
    You **cannot** mount an [SD Card to a CM with eMMC](https://www.reddit.com/r/retroflag_gpi/comments/snesyy/is_it_impossible_to_mount_the_sd_card_with_an/).
	
### References
- https://github.com/raspberrypi/usbboot
- https://www.raspberrypi.com/documentation/computers/compute-module.html#flashing-the-compute-module-emmc
- https://www.jeffgeerling.com/blog/2020/usb-20-ports-not-working-on-compute-module-4-check-your-overlays

## Method 2: Non-eMMC (CM4 Lite)

This method would be used for the CM4 Lite versions, which do not have eMMC storage. But is relatively simple and can be done with the Raspberry Pi Imager tool.

1. Download, install and start the [Raspberry PI Imager](https://www.raspberrypi.com/software/) for your host OS.
2. Select your preferred OS (for k3s you need a **64-bit** OS). Typically, the 64-bit lite version should be sufficient, unless you want full GUI support.
3. Select the SD Card to write to.
4. NOTE: In `Advanced options`, be sure to
    * set the **hostname** of your Pi to something unique and memorable (I chose `deskpi` followed by a number, e.g. `deskpi1`)
    * enable **passwordless** SSH
    * set a common **username** for all your Pi's (I chose `deskpi`), as well as an optional password.
    * configure Wireless LAN, if it is supported by your CM **(optional)**
5. Once completed, insert the SD Card into the CM's card slot.  
6. Repeat this for all CMs - the headless CM's do not need a desktop environment, so the 64-bit lite version of Raspberry Pi OS should be sufficient. Remember to change the hostname for every CM.
                                                
See the [Notes](#notes) section above for additional information.

## Method 3: Installing the OS to the NVMe SSD

You should ensure that you have enough disk space to accommodate the OS as well as the Kubernetes installation on the CM4. If you only have, say, 8GB of free space on the eMMC (or SD Card) of the CM4, 
the Kubernetes node may issue disk pressure warnings and may evict pods deployed on that node.

If your CM4s have **inadequate** disk storage on the eMMC (or SD Card) you may consider installing the OS to an NVMe SSD with sufficient storage. To do this we have to install the OS to the NVMe drive 
and update the boot order according to the [NVMe boot documentation](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#nvme-ssd-boot).

### Installing the OS to the NVMe SSD

There are a number of ways to accomplish this, unfortunately, they are a bit more complicated than just using the Raspberry Pi Imager tool to burn the OS to the eMMC or SD Card of the CM4. 

1. If you have a USB NVMe adapter (which you can buy on Amazon for around 20 euros), you can mount the SSD as a USB device and use the RPi Imager tool to burn the OS image to the SSD.
2. If you do not have an adapter, you could install **Raspberry Pi Desktop** to the CM4#1 (as described [above](#method-1-emmc-)), logon to the CM4 and use the _SD Card Copier_ app (found in the GUI) to clone the eMMC (or SD Card) of the CM4 to the SSD.
3. If you do not have access to a GUI desktop (as would be the case for all the RPi's apart from the one located in CM4#1 on the board), you could try **one** of the following methods to copy the image to the SSD:
   - Clone the image with [rpi-clone](https://github.com/billw2/rpi-clone) or
   - Use the [RPi Imager CLI](https://github.com/raspberrypi/rpi-imager/issues/460#issuecomment-1180525160)<br> 
     `rpi-imager --cli <image file to write> <destination drive device>` or    
   - Use [SDM](https://github.com/gitbls/sdm), a Raspberry Pi SSD/SD Card Image Manager utility.

### Updating the Boot Order

To update the boot order, we have to use Raspberry Pi's [usbboot/rpiboot](https://github.com/raspberrypi/usbboot) utility.

We will have to make/compile the utility, so ensure that you have the correct build packages installed:
```bash
sudo apt install git libusb-1.0-0-dev pkg-config build-essential
```

Clone the [rpiboot](https://github.com/raspberrypi/usbboot) repository:
```bash
git clone --depth=1 https://github.com/raspberrypi/usbboot
```

Build the `usbboot` tool from source:
```bash
cd usbboot
make
```

Open the `recovery/boot.conf` file and update the `BOOT_ORDER` and run `./update-pieeprom.sh` to update the `pieeprom.bin` file with the new settings
```bash
cd recovery
sed -i -e '/^BOOT_ORDER=/ s/=.*$/=0xf25416/' boot.conf
./update-pieeprom.sh
```
The boot type for NVMe is `6`, so that should be your first type, which means it should be the number at the end of the string.

We can now run the `rpiboot` utility and use it to flash the new bootloader configuration and firmware to the CM4 by connecting it in USB boot mode (as described above) and running:
```bash
cd ..
sudo ./rpiboot -d recovery
```

See the [Notes](#notes) section above for additional information.
                                                                               
#### References

- https://www.jeffgeerling.com/blog/2021/raspberry-pi-can-boot-nvme-ssds-now
- https://notenoughtech.com/raspberry-pi/it-took-me-2-months-to-boot-cm4-from-nvme

# 3. Cluster Preparation

Before starting this section, you should ensure that you have successfully installed the OS on all the CM4's, that they are connected to the network, and you can `ssh` onto all of them.

By default, Ansible uses native OpenSSH and by extension the options in `~/.ssh/config` to connect to the hosts in the inventory. I recommend a passwordless SSH connection to the CM4's, 
since Ansible has been known to have issues with password prompts.

Additionally, consider assigning static IPs to your CM4's in your DHCP server directly. This may uncomplicate things when you need to access the CM4's by hostname and your DNS has not been set up correctly (yet).

## Installation requirements

- python (>= v3.6)
- PyYAML (>= v3.11)  
- Ansible (>= v2.13) For detailed instructions on installing Ansible see the [Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

As well as the required Ansible Collections listed in the [requirements](requirements.yml) file. You can install these with the following command:
```bash
ansible-galaxy install -r requirements.yml
```

## Check the configuration of the cluster  

1. Update the [`inventory/hosts.yml`](inventory/hosts.yml) file
   - with the hostnames of the Pi's in your cluster
   - set the IP address octets (the last group of numbers in the IP address) to a range that is unoccupied in your network
2. In the [`inventory/group_vars/cluster.yml`](inventory/group_vars/cluster.yml)
   - set `ansible_user` to the username you defined for your Pi's during [Step 2](#step-2--install-the-os)  
   - set `ip_subnet_prefix` to the IP subnet prefix of your network
   - set `gateway` to the IP address of the gateway in your network
	                                                            
For example, if `ip_subnet_prefix` in the `config.yml` is defined as follows:
```yaml
ip_subnet_prefix: 192.168.1   
```
and the `hosts.ini` has the following content:
```yml
all:
  children:
    cluster:
      children:
        control_plane:
          hosts:
            deskpi1:
              ip_octet: 200
        nodes:
          hosts:
            deskpi2:
              ip_octet: 201
            deskpi3:
              ip_octet: 202
            deskpi4:
              ip_octet: 203
            deskpi5:
              ip_octet: 204
            deskpi6:
              ip_octet: 205
```
Then the server / master node has the hostname `deskpi1` and the ip address: `192.168.1.200` and the last node in the cluster has the hostname `deskpi6` and ip address `192.168.1.205`.
          
### Note
Keep in mind that this is not how Ansible resolves the ip address of the hosts in the inventory. It sees the hosts as `deskpi1`, `deskpi2`, etc. and relies on your DNS server to resolve the hostname 
to the correct IP address. If you do not have a DNS server, you can add the hostnames and IP addresses to the `/etc/hosts` file if you are using a Linux host, or the 
`C:\Windows\System32\drivers\etc\hosts` file if you are using Windows.

You can test the connection by ssh'ing into the hosts in the inventory:
```bash
ssh deskpi@deskpi1
```
Assuming `deskpi` is username you defined for your Pi's during [Step 2](#step-2--install-the-os) and the value of `ansible_user` in the `inventory/group_vars/cluster.yml` file.

### Consider assigning the Static IPs in your DHCP server directly

This can typically be done via your router configuration. 

### Use Ansible Vault for sensitive data
                         
Sensitive data such as passwords, API keys, etc. should be stored in an encrypted file using [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html).

The playbooks assume a [`playbooks/vars/vault.yml`](playbooks/vars/vault.yml) file exists and is encrypted.

To create a new encrypted file, run the following command from the project root:
```shell
ansible-vault create playbooks/vars/vault.yml
```
This will open an editor where you can add the sensitive data. Save and close the editor to encrypt the file.

To edit the encrypted file, run the following command from the project root:
```shell
ansible-vault edit playbooks/vars/vault.yml
```
        
You must provide the vault password when running the playbooks. 

This can be done via one the following methods: 

##### 1. Prompting for the password:
```shell
ansible-playbook playbooks/k3s-pre-install.yml --ask-vault-pass
```

##### 2. Store the password in a file and provide the file as an argument:
```shell
ansible-playbook playbooks/k3s-pre-install.yml --vault-password-file ~/.vault_pass.txt
```

##### 3. Set the `ANSIBLE_VAULT_PASSWORD_FILE` environment variable:
```shell
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass.txt
```

# 4. [Cluster Provisioning](playbooks/README.md) 

## 4.1 Pre-installation Playbook

It might be prudent to **manually** update and upgrade all software packages on each DeskPi after installation of the OS, at least once, before running the playbooks:

```bash
sudo apt update
sudo apt upgrade
```

to ensure that the DeskPi can communicate with the package repositories, and to respond to interactive input that is occasionally required (for example, for kernel updates or processor microcode upgrades). 

After which, from the **project root directory**, run the [preparation playbook](playbooks/k3s-pre-install.yml):

```bash
ansible-playbook playbooks/k3s-pre-install.yml
```

This playbook will, on every host in the cluster:

- Execute the [Cluster Preparation](roles/cluster-pre-install/README.md) role
- Configure an [NTP Client](roles/chrony/README.md)

On the Control Plane / Master Node this playbook will also:

- Configure an [NTP Server](roles/chrony/README.md)
- Set up a [DNS Server](roles/dnsmasq/README.md)

The reboot task may time out if the ip addresses of the CM4's were changed during the playbook run. 
Consequently, you may have to flush your dns cache before you will be able to connect to them again. 

## 4.2 [k3s](https://k3s.io/) Installation  Playbook

### Configuration

The cluster configuration is largely contained within [config.yml](playbooks/vars/config.yml) and consists of the following items:

* A kubelet configuration that enables [Graceful Node Shutdown](https://kubernetes.io/blog/2021/04/21/graceful-node-shutdown-beta/)
* Extra arguments for the k3s server installation (i.e. Control Plane / Master Node):
    - `--write-kubeconfig-mode '0644'` gives read permissions to Kube Config file (located at /etc/rancher/k3s/k3s.yaml)
    - `--disable servicelb` disables the default service load balancer installed by k3s (i.e. Klipper Load Balancer), instead we'll install MetalLB in a later step.
    - `--disable traefik` disables the default ingress controller installed by k3s (i.e. Traefik), instead we'll install Traefik ourselves in a later step.
    - `--kubelet-arg 'config=/etc/rancher/k3s/kubelet.config'` points to the kubelet configuration (see above).
    - `--kube-scheduler-arg 'bind-address=0.0.0.0'` exposes the 0.0.0.0 address endpoint on the Kube Scheduler for metrics scraping.
    - `--kube-proxy-arg 'metrics-bind-address=0.0.0.0'` exposes the 0.0.0.0 address endpoint on the Kube Proxy for metrics scraping.
    - `--kube-controller-manager-arg 'bind-address=0.0.0.0'` exposes the 0.0.0.0 address endpoint on the Kube Controller Manager for metrics scraping.
    - `--kube-controller-manager-arg 'terminated-pod-gc-threshold=10'` set a limit of 10 terminated pods that can exist before
      the [garbage collector starts deleting terminated pods](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-garbage-collection).
* Extra arguments for k3s agent installation (i.e. Worker Nodes)
    - `--node-label 'node_type=worker'`adds a custom label to the worker node.
    - `--kubelet-arg 'config=/etc/rancher/k3s/kubelet.config'` points to the kubelet configuration (see above).
    - `--kube-proxy-arg 'metrics-bind-address=0.0.0.0'` exposes the 0.0.0.0 address endpoint on the Kube Proxy for metrics scraping.

### Installation

Run the [k3s-install](playbooks/README.md#k3s-install) playbook from the **project root directory**:

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

## 4.3 Post-installation Playbook

After k3s has been successfully set up on your cluster, you must run the [k3s post-install](playbooks/README.md#k3s-post-install) playbook.

### Synopsis

This playbook does the following:

- Configures [kubectl autocompletion](https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/) and creates the alias `kc` for [`kubectl`](https://kubernetes.io/docs/reference/kubectl/), 
  which is automatically installed by the k3s installation script, on every host in the cluster.
- Installs [Helm](https://helm.sh/), the package manager for kubernetes, which will be used to install other k8s packages.
- Creates an [NFS Storage Class](../roles/nfs-storage/README.md), based on an NFS export, on the Control Plane.
- Updates [CoreDNS](https://docs.k3s.io/networking/networking-services#coredns) to use a replica count of 2 and forward DNS requests to public DNS servers.

### Configuration

Configuration variables can be found in the [vars/config.yml](vars/config.yml).
To configure the host as a local NFS Server, set the fact:
```yaml
local_nfs_server: true
```

Alternatively, to set the location of a **remote** NFS Server, set the facts:
```yaml
local_nfs_server: false
nfs_server: <ip_address_of_nfs>
```

In both cases ensure the path to the share is correct:
```yaml
nfs_path: <path_to_share>
```

### Installation

You run the post-install playbook from the **project root** as follows:

```bash
ansible-playbook playbooks/k3s-post-install.yml
```

The tasks are tagged and can be played individually via the `--tags` argument for `ansible-playbook`

For example, to install specifically only **Helm** you can run the playbook as follows:

```bash
ansible-playbook playbooks/k3s-post-install.yml --tags "helm" 
```
## 4.4 Additional Packages

Packages for k3s are declared in the [`k3s-packages-install`](playbooks/README.md#k3s-packages-install) playbook, they are tagged 
and can be played individually via the `--tags` argument for `ansible-playbook`.

| Package                                              | Tag           |
|------------------------------------------------------|---------------|
| [MetalLB](roles/metallb-install/README.md)           | `metallb`     |
| [Cert-Manager](roles/cert-manager-install/README.md) | `certmanager` |
| [Route53-DDNS](roles/route53-ddns-install/README.md) | `route53ddns` |
| [Traefik](roles/traefik-install/README.md)           | `traefik`     |
| [Longhorn](roles/longhorn-install/README.md)         | `longhorn`    |
| [Prometheus](roles/prometheus-install/README.md)     | `prometheus`  |
| [Linkerd](roles/linkerd-install/README.md)           | `linkerd`     |

### Installation

```bash
ansible-playbook playbooks/k3s-packages-install.yml 
```

Packages can be individually installed with the corresponding `tag`, for example:

```bash
ansible-playbook playbooks/k3s-packages-install.yml --tags "metallb,certmanager,traefik" 
```
                 
## 5. Uninstallation

## 5.1 [Uninstalling Packages](playbooks/README.md#k3s-packages-uninstall)

Remove the packages installed to k3s with the [`k3s-packages-uninstall`](playbooks/README.md#k3s-packages-uninstall) playbook, they are tagged 
and can be played individually via the `--tags` argument for `ansible-playbook`.

| Package                                                | Tag           |
|--------------------------------------------------------|---------------|
| [MetalLB](roles/metallb-uninstall/README.md)           | `metallb`     |
| [Cert-Manager](roles/cert-manager-uninstall/README.md) | `certmanager` |
| [Route53-DDNS](roles/route53-ddns-uninstall/README.md) | `route53ddns` |
| [Traefik](roles/traefik-uninstall/README.md)           | `traefik`     |
| [Longhorn](roles/longhorn-uninstall/README.md)         | `longhorn`    |
| [Linkerd](roles/linkerd-uninstall/README.md)           | `linkerd`     |

```bash
ansible-playbook playbooks/k3s-packages-uninstall.yml 
```

Packages can be individually uninstalled with the corresponding `tag`, for example:

```bash
ansible-playbook playbooks/k3s-packages-uninstall.yml --tags "metallb,certmanager,traefik" 
```

## 5.2 Uninstalling k3s

You can uninstall k3s by running the [k3s-uninstall](playbooks/README.md#k3s-uninstall) playbook:

```bash
ansible-playbook playbooks/k3s-uninstall.yml
```

## Additional Playbooks

### [update-deskpis.yml](playbooks/update-deskpis.yml)

Updates the software on all the Pi's in the cluster. Reboots them if required.

```bash
ansible-playbook playbooks/update-deskpis.yml
```

(Run from the project root directory)

### [reboot-deskpis.yml](playbooks/reboot-deskpis.yml)

Reboots all the Pi's in the cluster.

```bash
ansible-playbook playbooks/reboot-deskpis.yml
```

(Run from the project root directory)

### [shutdown-deskpis.yml](playbooks/shutdown-deskpis.yml)

Shuts down all the Pi's in the cluster.

```bash
ansible-playbook playbooks/shutdown-deskpis.yml
```

(Run from the project root directory)

### [update-route53-ddns.yml](playbooks/update-route53-ddns.yml)

Updates the DDNS records for the Pi's in the cluster using the [Route53 DDNS script](roles/route53-ddns-install/README.md).

```bash
ansible-playbook playbooks/update-route53-ddns.yml
```

(Run from the project root directory)
