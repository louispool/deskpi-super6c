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
```

Credentials for the admin user to create the necessary ISM policy and index template.
```yaml
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

### [Fluent Bit Configuration File](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/configuration-file)

The Fluent Bit configuration file is templated using Jinja2 and can be found in the [`templates/fluentbit-helm-values.yml.j2`](templates/fluentbit-helm-values.yml.j2) file. After installation, you can 
find the rendered configuration in the `fluent-bit` ConfigMap in the `logging` namespace. 

To effect changes you can edit the ConfigMap and restart the Fluent Bit pods, since Fluent Bit is installed as a DaemonSet, it will restart automatically after pod deletion.
```shell
kubectl delete pod -l app.kubernetes.io/name=fluent-bit -n {{ k3s_logging_namespace }}
```
        
#### A note on Variables and Record Accessors

The documentation is not clear on this, however, from my own experience I have determined that *variables* refer only to environment variables, while *record accessors* refer to fields in the log. 

Environment [variables](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/variables) can be accessed via the `${VAR_NAME}` syntax (note the braces), while 
[record accessors](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/record-accessor) use the `$field` syntax and `$field['sub-field']` to access a sub-field in a 
nested structure.

For example, given you are using the [`kubernetes` filter plugin](https://docs.fluentbit.io/manual/data-pipeline/filters/kubernetes) to enrich logs with Kubernetes metadata, you can access the 
namespace of the pod that emitted the log record using the syntax: 
```
$kubernetes['namespace_name']
```

When setting key-value pairs in a [Filter Plugin](https://docs.fluentbit.io/manual/data-pipeline/filters) like `modify` you are not setting variables, but rather modifying the log record itself. 

I have also discovered that accessing sub-fields in a nested structure using the `$field['sub-field']` syntax is not supported in all cases. Often, you can only access the top-level fields 
of the log record - therefore it is recommended to use [lua scripts](templates/fluentbit-lua-configmap.yaml.j2) to manipulate the log record - if you need to access sub-fields in a nested structure.

Additionally, unless a configuration parameter of plugin explicitly states that it supports *record accessor* syntax, you cannot assign a value to that parameter using the `$field['sub-field']` syntax.

For example, the `index` parameter in the `elasticsearch` output plugin does not support *record accessor* syntax, so given that you have set a log record called `log_prefix` the following will **not** work:
```
  Name  es
  Match *
  Host  192.168.2.3
  Port  9200
  index: $log_prefix
```

It will set the index name to the literal string **"$log_prefix"**, to which Elasticsearch will respond with a Bad Request error. Instead, you should enable `logstash_format` and set the `logstash_prefix_key` - 
which accepts the record accessors.
```
  Name  es
  Match *
  Host  192.168.2.3
  Port  9200
  logstash_format: on
  logstash_prefix_key: $log_prefix
```

## Testing
            
To verify that Fluent Bit is functioning correctly after installation, follow these steps:

#### 1. Check Fluent-Bit Pods Are Running:
```shell
kubectl get pods -n {{ k3s_logging_namespace }}
```
All pods should show STATUS: Running and READY: 1/1 (or more if multi-container).
To see logs:
```shell
kubectl logs -n {{ k3s_logging_namespace }} -l app.kubernetes.io/name=fluent-bit
```
Look for signs of successful input/output processing — e.g., entries like:
```
[info] [output:es:es.0] HTTP status=200
```

#### 2. Check Logs Are Being Collected
   
If you're collecting logs from containers:
```shell
kubectl logs -n kube-system -l app.kubernetes.io/name=fluent-bit
```
You should see log records being parsed and processed, e.g.:
```
[info] [input:tail:tail.0] inotify_fs_add(): ... name=/var/log/containers/*.log
```
If you enabled systemd as an input, also look for:
```
[info] [input:systemd:systemd.0] Successfully opened journal
```

#### 3. Verify Indexes in OpenSearch

Run this via API or with curl:
```
curl -u admin:your-password -k "https://{{ opensearch_rest_api }}/_cat/indices?v"
```

Look for indices like:
```plaintext
logs-<app-name>-YYYY.MM.DD
```            
Or whatever your configured pattern.

#### 4. Check OpenSearch Index Template
```shell
curl -u admin:your-password -k "https://{{ opensearch_rest_api }}/_index_template/fluentbit-template?pretty"
```
You should see a template with:

```json
"settings": {
"plugins.index_state_management.policy_id": "fluentbit-retention"
}
```

#### 5. Confirm Log Entries in OpenSearch

Use OpenSearch Dashboards or this query:
```shell    
curl -u admin:your-password -k "https://{{ opensearch_rest_api }}/logs-*/_search?pretty" -H 'Content-Type: application/json' -d '{ "size": 1, "sort": [{ "@timestamp": "desc" }] }'
```
You should get recent log events.

#### 6. Grafana Integration (Optional)

If you have imported a Fluent Bit dashboard in Grafana:

- Navigate to it
- Check panels like "Logs Ingested", "Error Rate", etc.

If panels show `No data`, it's often a sign of:

- Metric output not being enabled in Fluent Bit
- ServiceMonitor misconfiguration







