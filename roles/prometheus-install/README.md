# Role definition for installing [Prometheus](https://prometheus.io/), a powerful open-source monitoring and alerting toolkit.

```
├── roles
│  ├── prometheus-install
│  │  ├── defaults
│  │  │  ├── main.yml
│  │  ├── tasks 
│  │  │  ├── main.yml  
│  │  ├── templates
│  │  │  ├── alertmanager-dashboard.yml.j2
│  │  │  ├── grafana-dashboard.yml.j2
│  │  │  ├── grafana-dashboard-public.yml.j2
│  │  │  ├── prometheus-dashboard.yml.j2
│  │  │  ├── prometheus-helm-values.yml.j2
```
                  
## About

Prometheus is an open-source systems monitoring and alerting toolkit. This role uses Helm to install the 
[Kube-Prometheus stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) onto our k3s cluster.

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

Define the StorageClass for the Prometheus persistent volume via the variable `prometheus_storage_class`:
```yaml
prometheus_storage_class: longhorn
```
Specify the # Size of the Persistent Volume Claim (PVC) for Prometheus data storage:
```yaml
prom_storage_size: '30Gi'
```
Define the retention period for Prometheus data via the variable `prom_retention`:
```yaml
prom_retention: '7d'
```
This is the time period for which Prometheus will retain data before deleting it.

Define the internal endpoint for the Prometheus UI via the variable `prometheus_dashboard`:
```yaml
prometheus_dashboard: dashboard.prometheus.localnet
```

Define the internal endpoint for the Alertmanager UI via the variable `alertmanager_dashboard`:
```yaml
alertmanager_dashboard: dashboard.alertmanager.localnet
```

The admin credentials for Grafana can be configured via the variables:
```yaml
grafana_admin_user: admin
grafana_admin_passwd:  passwd  
```
Consider using Ansible Vault to encrypt these credentials for security.

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

Configure the Textfile Collector directory for the Node Exporter via the variable `node_exporter_textfile_directory`:
```yaml
node_exporter_textfile_dir: /var/lib/node_exporter/textfile_collector
```

## Scrape Targets

To scrape metrics from services running in the cluster you define a `ServiceMonitor` resource.

A `ServiceMonitor` is a Kubernetes custom resource provided by the Prometheus Operator that declaratively specifies how to scrape metrics from a service. 
It tells Prometheus where to find metrics endpoints, how often to scrape them, and how to label the resulting metrics. 

To enable monitoring for your application, ensure it exposes a Prometheus-compatible /metrics endpoint and create a `ServiceMonitor` like the example below:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app
  namespace: monitoring
  labels:
    release: kube-prometheus-stack
spec:
  selector:
    matchLabels:
      app: my-app
  namespaceSelector:
    matchNames:
      - my-app-namespace
  endpoints:
    - port: metrics
      path: /metrics
      interval: 15s
```
This configuration tells Prometheus (installed via the kube-prometheus-stack Helm chart) to scrape metrics from the metrics port on any Service labeled `app: my-app` in the `my-app-namespace` namespace.
Make sure the Service and the corresponding metrics endpoint are available, and that the **release label matches your Prometheus release name**.

## Alerting Rules

A `PrometheusRule` is a Kubernetes custom resource used to define Prometheus alerting and recording rules. These rules allow you to trigger alerts based on specific metric conditions or precompute
time-series expressions. They are managed by the Prometheus Operator and automatically picked up by Prometheus instances configured to watch the rule's namespace. 

Here's a simple example that defines a high CPU usage alert:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: app-alerts
  namespace: monitoring
  labels:
    release: kube-prometheus-stack
spec:
  groups:
    - name: app.rules
      rules:
        - alert: HighCpuUsage
          expr: rate(container_cpu_usage_seconds_total{pod="my-app"}[5m]) > 0.8
          for: 2m
          labels:
            severity: warning
          annotations:
            summary: "High CPU usage detected on my-app"
            description: "Container my-app is using over 80% CPU for more than 2 minutes."
```
This rule triggers a `HighCpuUsage` alert if the `my-app` pod exceeds 80% CPU usage for 2 minutes. Make sure the **release label matches your Prometheus installation** for proper rule discovery.

## Node Exporter's [Textfile Collector](https://github.com/prometheus/node_exporter?tab=readme-ov-file#textfile-collector)

The Node Exporter includes a ["textfile collector"](https://github.com/prometheus/node_exporter?tab=readme-ov-file#textfile-collector) that allows you to expose custom metrics by writing them to 
files in a specific directory. The Node Exporter will read these files and expose the metrics - this is handy for monitoring machine-level cronjobs or services.

The Helm values template [`prometheus-helm-values.yml.j2`](templates/prometheus-helm-values.yml.j2) configures the Node Exporter to enable the Textfile Collector, reading `.prom` files from 
`node_exporter_textfile_dir` (default: `/var/lib/node_exporter/textfile_collector`) on the machine host. 
       
To test whether the Textfile Collector is working, pick the pod that is running on the node you want to check:
```bash
kubectl -n monitoring get pods -o wide
````

SSH into the node and create a sample metric file in the Textfile Collector directory (the exampl below assumes the default directory at `/var/lib/node_exporter/textfile_collector`):
```bash
echo 'test_metric{label="foo"} 42' | sudo tee /var/lib/node_exporter/textfile_collector/test.prom
```
    
Then query the metric service inside the pod you identified earlier:
```bash
kubectl -n monitoring exec -it kube-prometheus-stack-prometheus-node-exporter-<pod-identifier> -- wget -qO- http://127.0.0.1:9100/metrics | grep test_metric
```

You should see the output:
```
test_metric{label="foo"} 42
```
     @
## Importing Grafana Dashboards

Grafana dashboards can be provisioned declaratively by storing them in Kubernetes `ConfigMaps`. 

To get started, download a dashboard JSON from [Grafana’s official dashboard library](https://grafana.com/grafana/dashboards/), or export one from your Grafana instance. 
Save the JSON file locally (e.g., `traefik-dashboard.json`) and create a ConfigMap so that Grafana’s sidecar can pick it up automatically:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: traefik-dashboard
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  traefik-dashboard.json: |
    {
      "__inputs": [],
      "title": "Traefik Metrics",
      ...
    }
```
Note the label `grafana_dashboard: "1"`. Grafana must be deployed with the sidecar dashboard loader (enabled by default in `kube-prometheus-stack`). 
This setup automatically scans for labeled ConfigMaps and imports the dashboards into Grafana.

### Why replace uid and id?
In Grafana, each dashboard has a unique identifier (`uid`) and an internal ID (`id`). When importing dashboards, you may need to replace these identifiers for the following reasons:

- `uid` must be unique across your Grafana instance. If you're uploading a dashboard with a `uid` that already exists (e.g. from a previous dashboard or provisioned one), Grafana may reject it or refuse to
overwrite it.
- `id` is a Grafana.com identifier and should be omitted when uploading to your own instance. Grafana will auto-assign an internal ID.



