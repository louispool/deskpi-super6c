# Ansible Role definition for tasks to be run **before** k3s installation

```
├── roles
│  ├── cluster-pre-install
│  │  ├── defaults
│  │  │  ├── main.yml
│  │  ├── files
│  │  │  ├── ...
│  │  ├── handlers
│  │  │  ├── main.yml
│  │  ├── tasks 
│  │  │  ├── cmdline.yml
│  │  │  ├── control_groups.yml
│  │  │  ├── main.yml  
│  │  │  ├── networking.yml
│  │  │  ├── remove_snap.yml
│  │  │  ├── remove_snap_packages.yml
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for the various tasks that prepare the DeskPi cluster **before** 
k3s installation.  

### Synopsis

This role does the following:
     
- Lowers the memory reserved for the GPU (if specified)
- Disables the USB-PD current limit on CM5's (if specified)
- Updates and installs prerequisite software packages
- Sets up the `cpuset` and `memory` control groups
- Configures a static ip (with the ip-addresses as configured in the [inventory](../../inventory/hosts.yml))
- Switches to legacy `ip-tables` **(if required)**
- Configures `etc/hosts` so that the DeskPi's can see each other by hostname
- Sets the DNS server on `systemd-resolved`
- Reboots the DeskPi (if necessary)
<br><br>
- When Ubuntu is installed on the DeskPi:
  - Removes the 'snap' package manager
  - Disables network configuration via cloud-init
  - Configures a static ip with Netplan
  - Configures Cloud Config to 
    - allow modification of `etc/hosts`
    - prevent cloud-init from updating `etc/hostname`
<br><br>    
- Copies over scripts and file resources
  - `.bashrc` 
  - `.bash_functions`
  - `.vimrc`
  - `pi_temp.sh` (script for monitoring the temperature of the CM)
  - `pi_throttling.sh` (script for reporting any throttling of the CM) 

**Note:** The reboot task may time out if the ip addresses of the DeskPi's were changed during the playbook run. 
Consequently, you may have to flush your dns cache before you will be able to connect to them again.

### Configuration

Set whether Ubuntu Server was installed as the OS on the DeskPi's via the variable `ubuntu_server`:
```yaml
ubuntu_server: true
```
Set whether to lower the memory reserved for the GPU via the variable `reduce_gpu_memory`:
```yaml
reduce_gpu_mem: true
```
Configure whether to disable the USB-PD current limit on CM5's via the variable `disable_usb_pd_current_limit`:
```yaml
disable_usb_pd_current_limit: true
```
Sets whether to format the available SD card on the DeskPi's via the variable `format_sd_card`:
```yaml
format_sd_card: true
```






