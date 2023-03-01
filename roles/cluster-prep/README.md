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
|  |  |  ├── main.yml  
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for the various tasks that prepare the DeskPi cluster before k3s installation.  

This role defines tasks that will, on every DeskPi in the cluster:

- Enable cpuset and memory control groups
- Configure a static ip (with the ip-address as configured in the [inventory](../../inventory/hosts.yml)))
- Add required software dependencies
- Update all software packages
- Switch to legacy ip-tables **(if required)**
- Copy over scripts and file resources
- Reboot the Pi

The reboot task may time out if the ip addresses of the Pi's were changed during the playbook run. Consequently, you may have to flush your dns cache before you will be able to connect to them again.