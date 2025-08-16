# Ansible Role definition for tasks to be run *after* installing Prometheus Monitoring  
```
├── roles
│  ├── prometheus-post-install
│  │  ├── files
│  │  │  ├── longhorn-grafana-dashboard.json
│  │  │  ├── traefik-grafana-dashboard.json
│  │  ├── tasks 
│  │  │  ├── main.yml  
│  │  ├── templates
│  │  │  ├── longhorn-prometheus-rules.yml.j2
│  │  │  ├── longhorn-service-monitor.yml.j2
│  │  │  ├── traefik-prometheus-rules.yml.j2
│  │  │  ├── traefik-service-monitor.yml.j2
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for the various tasks that should be run *after* installing Prometheus Monitoring on the DeskPi cluster.

### Synopsis

This role does the following:

- Deploys the Longhorn and Traefik service monitors to the cluster.
- Deploys the Longhorn and Traefik Prometheus rules to the cluster.
- Deploys the Longhorn and Traefik Grafana dashboards to the cluster.


