# Role definition for uninstalling [OpenSearch](https://opensearch.org/)

```
├── roles
│  ├── opensearch-uninstall
|  |  ├── defaults 
|  |  |  ├── main.yml  
|  |  ├── tasks 
|  |  |  ├── main.yml  
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for [uninstalling OpenSearch](https://docs.opensearch.org/docs/latest/install-and-configure/install-opensearch/helm/#uninstall-using-helm).

## Synopsis

This role does the following:
- Uninstalls the OpenSearch Dashboards Helm chart (if installed).
- Uninstalls the OpenSearch Helm chart.
- Removes all Ingress Routes from the OpenSearch namespace.
- Removes all Certificates from the OpenSearch namespace. 
- Deletes all PVCs in the OpenSearch namespace.
- Untaints the OpenSearch nodes (if tainted during install).
- Deletes the OpenSearch namespace.
 
