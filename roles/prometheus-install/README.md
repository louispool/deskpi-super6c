# Role definition for installing [Prometheus](https://prometheus.io/) Monitoring

```
├── roles
│  ├── prometheus-install
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── tasks 
|  |  |  ├── main.yml  
|  |  ├── templates
|  |  |  ├── grafana-dashboard.yml.j2
|  |  |  ├── grafana-dashboard-public.yml.j2
|  |  |  ├── prometheus-helm-values.yml.j2
```
                  
## About

Prometheus is an open-source systems monitoring and alerting toolkit. This role uses Helm to install the 
[Kube-Prometheus stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) onto our k3s cluster.
e systems monitoring and alerting toolkit. This role uses Helm to install the
[Kube-Prometheus stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
The `kube-prometheus-stack` is a comprehensive Helm chart that deploys a full monitoring stack for Kubernetes. It includes:

- [Prometheus](https://prometheus.io/): Collects and stores metrics from Kubernetes and applications.
- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator): Manages Prometheus instances and related resources using Kubernetes CRDs.
- [Prometheus Node Exporter](https://github.com/prometheus/node_exporter): An agent that runs on each Kubernetes node and exposes hardware and OS-level metrics.
- [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/): Handles alerts sent by Prometheus, including routing and notifications.
- [Grafana](https://grafana.com/): Provides dashboards for visualizing metrics.
- [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics): Exposes cluster-level metrics about the state of Kubernetes objects.
- Custom Resource Definitions (CRDs): Such as `ServiceMonitor`, `PodMonitor`, and `PrometheusRule` for flexible monitoring and alerting.

The stack automates setup, configuration, and management of monitoring components, making it easy to monitor Kubernetes clusters and workloads with minimal manual intervention. It is highly
customizable via Helm values and supports integrations with many exporters and dashboards.
        
### Preconfigured Scrape Targets

Helm and Kube-Prometheus pre-configure these components to scrape several endpoints in our cluster by default.

Such as, among others, the
- `cadvisor`
- `kubelet`
- node-exporter `/metrics` endpoints on K8s Nodes,
- K8s API server metrics endpoint
- kube-state-metrics endpoints

To see a full list of configured scrape targets, refer to the Kube-Prometheus Helm
chart’s [values.yaml](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml).

You can find scrape targets by searching for `serviceMonitor` objects. To learn more about configuring the Kube-Prometheus stack’s scrape targets, see the `ServiceMonitor` spec in
the [Prometheus Operator GitHub repo](https://github.com/prometheus-operator/prometheus-operator).

### Mixins

The Kube-Prometheus stack also provisions several monitoring [mixins](https://github.com/monitoring-mixins/docs). A 'mixin' is a collection of prebuilt Grafana dashboards, Prometheus recording rules,
and Prometheus alerting rules.

In particular, it includes:

- The [Kubernetes Mixin](https://github.com/kubernetes-monitoring/kubernetes-mixin), which includes several useful dashboards and alerts for monitoring K8s clusters and their workloads
- The [Node Mixin](https://github.com/prometheus/node_exporter/tree/master/docs/node-mixin), which does the same for 'Node Exporter' metrics
- The [Prometheus Mixin](https://github.com/prometheus/prometheus/tree/main/documentation/prometheus-mixin)

Mixins are written in [Jsonnet](https://jsonnet.org/), a data templating language, and generate JSON dashboard files and rules YAML files.

To learn more, check out

- [Generate config files](https://github.com/monitoring-mixins/docs#generate-config-files) (from the Prometheus Monitoring Mixins repo)
- [Grizzly](https://github.com/grafana/grizzly)  (a tool for working with Jsonnet-defined assets against the Grafana Cloud API)

## Configuration

Configure the namespace for the Prometheus deployment via the variable `k3s_monitoring_namespace`:
```yaml
k3s_monitoring_namespace: monitoring
```

Configure whether to enable the [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) via the variable `prom_alertmanager_enabled`:
```yaml
prom_alertmanager_enabled: true
```

Configure whether to enable the [Node Exporter](https://github.com/prometheus/node_exporter) via the variable `prom_node_exporter_enabled`:
```yaml
prom_node_exporter_enabled: true
```

Configure whether to enable [Kube State Metrics](https://github.com/kubernetes/kube-state-metrics) via the variable `prom_kube_state_metrics_enabled`:
```yaml
prom_kube_state_metrics_enabled: true
```

Define the internal endpoint for the Prometheus UI via the variable `prometheus_dashboard`:
```yaml
prometheus_dashboard: dashboard.prometheus.localnet
```

Define the internal endpoint for the Alertmanager UI via the variable `alertmanager_dashboard`:
```yaml
alertmanager_dashboard: dashboard.alertmanager.localnet
```

Access to the Prometheus UI is restricted via basic auth, the user and password can be configured as follows:        
```yaml
prometheus_basic_auth_user: admin
prometheus_basic_auth_passwd: passwd
```
Consider using Ansible Vault to encrypt these credentials for security.

Access to the Alertmanager UI is also restricted via basic auth, the user and password can be configured as follows:
```yaml
alertmanager_basic_auth_user: admin
alertmanager_basic_auth_passwd: passwd
```
Consider using Ansible Vault to encrypt these credentials for security.
      
Define the endpoint to Grafana via the variable `grafana_dashboard`:
```yaml
grafana_dashboard: dashboard.grafana.localnet
```

Define the endpoint to the public Grafana dashboard via the variable `public_grafana_dashboard`:
```yaml
public_grafana_dashboard: dashboard.grafana.example.com
```

Configure whether to enable the public Grafana dashboard via the variable `enable_public_grafana_dashboard`:
```yaml
enable_public_grafana_dashboard: true
```

The admin credentials for Grafana can be configured via the variables:
```yaml
grafana_admin_user: admin
grafana_admin_passwd:  passwd  
```
Consider using Ansible Vault to encrypt these credentials for security.
