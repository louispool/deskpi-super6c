# Ansible Playbooks

```
├── playbooks
│ ├── tasks
| |  ├── cmdline.yml
| |  ├── reboot.yml
│ ├── tests
| |  ├── ...
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
This structure houses the Ansible Playbooks.

### [k3s-pre-install](k3s-pre-install.yml)

Playbook prepares the cluster for k3s installation.   
                                                   
From the **project root directory**, run:
```bash
ansible-playbook playbooks/k3s-pre-install.yml
```

This playbook will, on every Pi:

- Enable cpu and memory control groups
- Configure a static ip (with the ip-address as configured in [hosts.yml](../inventory/hosts.yml))
- Add required software dependencies
- Update all software packages
- Switch to legacy ip-tables (if required)
- Copy the `.*rc` files in the `resources` folder
- Reboot the Pi

The reboot task may time out if the ip addresses of the Pi's were changed during the playbook run.
Consequently, you may have to flush your dns cache before you will be able to connect to them again.

### [k3s-install](k3s-install.yml)

After running the preparation playbook it's time to install [k3s](https://k3s.io/).

1. Run the [k3s-install.yml](playbooks/k3s-install.yml) playbook from the **project root directory**:
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

### [k3s-uninstall](k3s-uninstall.yml)

You can uninstall k3s by running the [`k3s-uninstall.yml`](playbooks/k3s-uninstall.yml) playbook from the **project root**:

```bash
ansible-playbook playbooks/k3s-uninstall.yml
```

### [k3s-post-install](k3s-post-install)

After k3s has been successfully set up on your cluster, you can run the post-install playbook from the **project root**:

```bash
ansible-playbook playbooks/k3s-post-install.yml
```
This playbook will do the following:   

- [Helm](https://helm.sh/), the package manager for kubernetes, is installed, and we will use it to install other packages.
- [kubectl autocompletion](https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/) and the alias `kc` is created for [`kubectl`](https://kubernetes.io/docs/reference/kubectl/), which is automatically installed by the k3s installation script, on every Pi in the cluster.
- Creates an Ingress Route to the [Traefik Dashboard](https://doc.traefik.io/traefik/operations/dashboard/) and exposes the dashboard at `<your-deskpi-ip>/dashboard/`. [Traefik](https://traefik.io/) is the default Ingress Controller installed for kubernetes by k3s. 

- An [NFS Storage Class](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner), based on an NFS export, is created on the `control_plane` host.

These playbooks are tagged and can be played individually via the `--tags` argument for `ansible-playbook`

For example, to install specifically only **Helm** you can run the playbook as follows:

```bash
ansible-playbook playbooks/k3s-post-install.yml --tags "helm" 
```
     
### [k3s-packages-install](k3s-packages-install.yml)

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