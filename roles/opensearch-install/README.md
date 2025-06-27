# Role definition for installing [OpenSearch](https://opensearch.org/)

```
├── roles
│  ├── opensearch-install
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── tasks 
|  |  |  ├── main.yml  
|  |  ├── templates
|  |  |  ├── opensearch-helm-values.yml.j2
|  |  |  ├── opensearch-rest-api.yml.j2
|  |  |  ├── opensearch-transport-cert.yml.j2
```

## About

OpenSearch is a distributed search and analytics engine based on Apache Lucene, an opensource fork of Elasticsearch and Kibana following the license change in early 2021. 
OpenSearch enables full-text searches on ingested data with features such as: 
- Searching by Field 
- Searching multiple Indexes 
- Field Boosting 
- Ranking results by Score
- Sorting results by Field 
- Result Aggregation

## Synopsis

This role does the following:
1. Creates a namespace for the OpenSearch deployment.
2. Deploys the [OpenSearch Helm chart](https://opensearch.org/docs/latest/install-and-configure/helm/) with values that specify:
   - the OpenSearch cluster name and node group
   - the OpenSearch version to install
   - the OpenSearch admin secret
   - the OpenSearch replicas
   - the OpenSearch resources limits and requests
   - the OpenSearch PVC size and storage class
3. Configures the OpenSearch REST API and Transport Layer certificates.
4. Exposes the OpenSearch REST API via an IngressRoute on the local network
5. Exposes the OpenSearch Dashboards via:
   - an IngressRoute on the local network
   - an IngressRoute on the internet (if `enable_public_opensearch_dashboard` is set to `true`).

## Configuration

Configure the namespace for the Opensearch deployment via the variable `k3s_opensearch_namespace`:
```yaml
k3s_opensearch_namespace: opensearch
```
     
Configure the [version](https://docs.opensearch.org/docs/latest/version-history/) of OpenSearch to install via the variable `opensearch_version`:
```yaml
opensearch_version: "3.0.0"
```

Configure the name and group name of the OpenSearch cluster via the variables `opensearch_cluster_name` and `opensearch_node_group` respectively:
```yaml
opensearch_cluster_name: "opensearch-cluster"
opensearch_node_group: "master"
```
From these variables Kubernetes will create resources named like:
```shell
opensearch-cluster-master-0
svc/opensearch-cluster-master
``` 

The following configuration properties taints the specified nodes in your cluster to repel general workloads and reserve those nodes for OpenSearch, and compels the scheduler to schedule the OpenSearch
pods onto only the specified nodes.
```yaml
opensearch_nodes:
  - deskpi2
  - deskpi3
  - deskpi4
  
opensearch_enable_node_tolerations: true
```

Configure the size of the OpenSearch cluster (i.e. number of instances/pods - each scheduled on a separate node) via the variable `opensearch_replicas`:
```yaml
opensearch_replicas: 3
```

The following configuration properties define the resource requirements of the OpenSearch pods. Consider the limitations of your hardware - note that the 
[OpenSearch Requirements](https://github.com/opensearch-project/helm-charts/tree/main/charts/opensearch#requirements) recommends 8GB of memory per pod, or at minimum 4GB of memory, otherwise the deployment will fail.
```yaml
opensearch_resources_limits_memory: "5Gi"
opensearch_resources_limits_cpu: "2000m"

opensearch_resources_requests_memory: "2Gi"
opensearch_resources_requests_cpu: "1000m"
```
                                                                                                                                                       
Configure the size of the Persistent Volume Claim (PVC) for OpenSearch data storage via the variable `opensearch_pvc_size` and the storage class via `opensearch_storage_class`:
```yaml
opensearch_pvc_size: "30Gi"
opensearch_storage_class: "longhorn"
```

Define the internal endpoint for the OpenSearch REST API via the variable `opensearch_rest_api`:
```yaml
opensearch_rest_api: "api.opensearch.localnet"
```

Define the endpoint to the OpenSearch Dashboard via the variable `opensearch_dashboard`:
```yaml
opensearch_dashboard: "dashboard.opensearch.localnet"
```

Define the endpoint to the public Grafana Dashboard via the variable `public_opensearch_dashboard`:
```yaml
public_opensearch_dashboard: dashboard.opensearch.example.com
```

Configure whether to enable the public Opensearch Dashboard via the variable `enable_public_opensearch_dashboard`:
```yaml
enable_public_opensearch_dashboard: true
```

Defines the password for the OpenSearch admin user. The password is required, without it installation will fail.
```yaml
opensearch_admin_passwd: "!s3cr3t"
```
*Note that this should be overridden by a vault variable.*

Whether to enable prometheus monitoring via plugin. **Important**, the exporter plugin must match the version of OpenSearch.
```yaml
opensearch_enable_monitoring: false
```
