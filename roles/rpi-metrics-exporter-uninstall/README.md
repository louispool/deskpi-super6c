# Role definition for uninstalling the Raspberry Pi Metrics Exporter

```
├── roles
│  ├── rpi-metrics-exporter-uninstall
│  │  ├── defaults 
│  │  │  ├── main.yml  
│  │  ├── tasks 
│  │  │  ├── main.yml  
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles)
for uninstalling the Raspberry Pi Metrics Exporter.

## Synopsis

This role does the following:

1. Stops, disables and removes the rpi-metrics-exporter timer and service.
2. Removes the rpi-metrics-exporter script
3. Removes the Node Exporter textfile collector output file.
4. Reloads systemd to apply changes.
