# Role definition for installing [Fluent Bit](https://fluentbit.io/), a lightweight and efficient log processor and forwarder.

```
├── roles
│  ├── fluentbit-install
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── tasks 
|  |  |  ├── main.yml  
|  |  ├── templates
|  |  |  ├── fluentbit-helm-values.yml.j2
```

## About
Fluent Bit is a lightweight and efficient log processor and forwarder, designed to collect, process, and ship logs from various sources to different destinations. 
It is particularly well-suited for resource-constrained environments like the DeskPi Cluster.

This role assumes that the OpenSearch cluster is installed and running, and the OpenSearch REST API is accessible via the property `opensearch_rest_api`.

## How logging works in the DeskPi Cluster

In Kubernetes, you don’t need to annotate individual pods to make logs accessible to Fluent Bit.
#### Log Flow (Default Kubernetes behavior)
1. Containers write logs to stdout/stderr.
2. The container runtime (e.g., `containerd` or `Docker`) automatically redirects stdout/stderr to a file on the host filesystem:
   - `/var/log/containers/*.log` (symlinks)
   - These point to `/var/log/pods/<pod>/<container>/*.log`
3. These logs are JSON-formatted by default.

#### Fluent Bit DaemonSet
1. When deployed as a `DaemonSet`, Fluent Bit runs once on each node.
2. It mounts `/var/log/containers`, `/var/log/pods`, and `/var/lib/docker/containers` (if needed).
3. It tails the files in `/var/log/containers/*.log`
4. It enriches them with Kubernetes metadata via its kubernetes filter plugin (via pod name, container name, labels, etc.).
5. It then forwards the enriched logs to the configured output (e.g. OpenSearch).

## Synopsis

This role does the following:
1. Validates that the OpenSearch server is running and the REST API is accessible via the property `opensearch_rest_api`.
2. Creates an ISM policy and an index template on OpenSearch for log rotation and retention.
3. Creates a namespace for the Fluent Bit deployment.
4. Deploys the [Fluent Bit Helm chart](https://github.com/fluent/helm-charts) with values that specify:
   - a config defining
     - **inputs** for collecting container logs and system logs
     - **filters** for enriching logs with Kubernetes metadata
     - **outputs** for sending logs to OpenSearch, such that 
       - every application log is sent to a dedicated index named after the app suffixed with `-logs` (e.g. `traefik-logs`) 
       - and system logs are sent to a dedicated index named `system-logs`.
   - a metrics service that exposes Fluent Bit metrics for Prometheus, accompanied by a
       - ServiceMonitor
       - PrometheusRule
       - and Grafana dashboard

## Configuration

Configure the namespaces necessary for the Fluent Bit deployment:
```yaml
# Namespace to install Fluent Bit and its dependencies
k3s_logging_namespace: "logging"
# Namespace where the monitoring stack is installed (e.g., Prometheus, Grafana)
k3s_monitoring_namespace: "monitoring"
# Namespace where the OpenSearch cluster is installed
k3s_opensearch_namespace: "opensearch"
```

Configure the OpenSearch REST API endpoint for access the local network:
```yaml
opensearch_rest_api: "api.opensearch.localnet"
```

Configure the details of OpenSearch cluster:
```yaml
opensearch_cluster_name: "opensearch-cluster"
opensearch_node_group: "master"
```
This is necessary for the fluentbit deployment to communicate directly with the OpenSearch cluster using the cluster-local DNS.

Configure the credentials necessary for Fluent Bit to authenticate with OpenSearch:
```yaml
opensearch_logger_user: "logger"
opensearch_logger_passwd: "!s3cr3t"

opensearch_admin_user: "admin"
opensearch_admin_passwd: "!s3cr3t"
```

Configure the size at which logs should be rotated:
```yaml
log_rollover_size: "5gb"
```
Configure the retention period for the logs:
```yaml
log_retention_period: "7d"  
```

Log rollover and retention are configured via an Index State Management (ISM) policy in OpenSearch, which is created by this role.
When an index reaches the specified size, it is rolled over to a new index. The old index is renamed and retained for the specified period before being deleted.








