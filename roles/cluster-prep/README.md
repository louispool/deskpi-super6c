# Ansible Role definition for Cluster Preparation

```
├── roles
│  ├── cluster-prep
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── files
|  |  |  ├── ...
|  |  ├── handlers
|  |  |  ├── main.yml
|  |  ├── tasks 
|  |  |  ├── cmdline.yml
|  |  |  ├── control_groups.yml
|  |  |  ├── main.yml  
|  |  |  ├── networking.yml
|  |  |  ├── remove_snap.yml
|  |  |  ├── remove_snap_packages.yml
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for the various tasks that prepare the DeskPi cluster before k3s installation.  

### Synopsis

This role does the following:

- Adds required software dependencies
- Updates all software packages
- Enables `cpuset` and `memory` control groups
- Configures a static ip (with the ip-address as configured in the [inventory](../../inventory/hosts.yml))
- Switches to legacy `ip-tables` **(if required)**
- Copies over scripts and file resources
- Configures `etc/hosts` so that the DeskPi's can see each other by hostname
- Sets the DNS server on `systemd-resolved`
- Reboots the DeskPi (if necessary)


- When Ubuntu is installed on the DeskPi:
  - Removes the 'snap' package manager
  - Disables network configuration via cloud-init
  - Configures a static ip with Netplan
  - Configures Cloud Config to 
    - allow modification of `etc/hosts`
    - prevent cloud-init from updating `etc/hostname`

The reboot task may time out if the ip addresses of the DeskPi's were changed during the playbook run. Consequently, you may have to flush your dns cache before you will be able to connect to them again.