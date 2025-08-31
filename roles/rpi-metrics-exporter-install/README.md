# Role definition for installing and configuring the Raspberry Pi Metrics Exporter.

```
├── roles
│  ├── rpi-metrics-exporter
│  │  ├── defaults
│  │  │  ├── main.yml
│  │  ├── tasks
│  │  │  ├── main.yml 
│  │  ├── templates
│  │  │  ├── vcgencmd_exporter.service.j2
│  │  │  ├── vcgencmd_exporter.sh.j2
│  │  │  ├── vcgencmd_exporter.timer.j2
```
This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for installing and configuring the Raspberry Pi Metrics Exporter.

The exporter collects metrics from the machine host, such as CPU temperature, voltage, and clock speeds using [`vcgencmd`](https://www.raspberrypi.com/documentation/computers/os.html#vcgencmd),
and makes them available to Prometheus via Node Exporter's ["textfile collector"](https://github.com/prometheus/node_exporter?tab=readme-ov-file#textfile-collector).

## Synopsis

This role does the following:

1. Ensures the textfile collector directory exists on the host.
2. Deploys the `vcgencmd` exporter script 
3. As well as the corresponding systemd service and timer unit files.

This role assumes that Prometheus and Node Exporter is already installed and running on the host.

