# Using OpenSearch

## 1. Discover Logs (like Splunk’s Search tab)
   
This is done via **Discover** in OpenSearch Dashboards.

First you will need to create an index pattern that matches your logs, such as `logs-traefik*` or `logs-*`. 
- Navigate to **Dashboards Management** in the left-hand menu.
- Select **Index Patterns**.
- Click **Create index pattern**.
- Enter your index pattern (e.g. `logs-traefik*`).
- Choose the timestamp field (usually `@timestamp`).

After that, you can explore logs in a way similar to Splunk's Search tab.

- Navigate to **Discover** in the left-hand menu.
- At the top, select your index pattern — e.g. `logs-traefik*`.
- You'll see a table view of log documents with a timestamp-based histogram.
- You can:
  - Expand each log entry to see all fields.
  - Filter by field values via the UI.
  - Create saved searches for common queries.

This is equivalent to Splunk’s **verbose mode** where you explore full event contents.

## 2. Querying in OpenSearch Dashboards

OpenSearch supports multiple query languages, each suited to a different use case:

| Language                            | Where it's used                       | Description                                         |
| ----------------------------------- | ------------------------------------- | --------------------------------------------------- |
| **DQL** (Dashboards Query Language) | **Discover**, filters, basic searches | Simple and human-readable                           |
| **Lucene Query Syntax**             | Legacy syntax, still accepted         | Keyword-oriented search                             |
| **OpenSearch Query DSL**            | API queries, scripted visualizations  | JSON-based, very powerful                           |
| **PPL** (Piped Processing Language) | Query Workbench                       | SQL-like with `pipe` support, great for time-series |

### Dashboards Query Language (DQL) — the default in Discover

*DQL* is a simplified query language modeled on Kibana's *KQL* (Kibana Query Language). It supports:

- Fielded search
- Boolean logic
- Wildcards
- Range queries
- Autocomplete in Discover

#### Example (*applicable to traefik logs*)                        

All logs where the requested host was for "opensearch" and the origin return code was 400 or greater
```
RequestHost: opensearch* AND OriginStatus >= 400
```
*You don’t need to wrap field names or strings in quotes unless there's a space.*

### Lucene Query Syntax (Legacy)

Still supported but being phased out in favor of DQL. It's similar to DQL but:

- Doesn’t support autocomplete
- Doesn’t allow scripted fields
- Often uses stricter formatting

#### Example (*applicable to traefik logs*)
```
RequestHost:opensearch* AND OriginStatus:[400 to 599]
```

### PPL (Piped Processing Language)
Enable this via the **Query Workbench** for advanced querying and exploration.

#### Example (*applicable to traefik logs*)
```
source = logs-traefik
| where level = 'error'
| stats count() as errors
```

Note: if you get a message like the following when you try to run a query in the Query Workbench:
```
"Events: Service Unavailable, this query is not runnable."
```
It might mean that the SQL engine plugin has to "wake up" to fully initialize inside OpenSearch. 
                                                                                                 
To trigger this, you can try running the following `curl` command:
```
curl -u admin -X POST "https://opensearch.deskpi.localnet/_plugins/_sql" -H 'Content-Type: application/json' -d'{"query":"SHOW TABLES LIKE \"%\""}'
```

### Query DSL (for APIs and automation)

Used mostly via:

- REST API requests
- Saved object definitions
- Dev tools

#### Example (*applicable to traefik logs*)

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "k8s_app": "traefik" }},
        { "range": { "OriginStatus": { "gte": 400, "lte": 599 }}}
      ]
    }
  },
  "size": 1000
}
```

## 3. Visualizations (like Splunk’s Dashboards)

For dashboards and time-series charts:

- Go to "Visualize" in the left-hand menu.
- Create a Lens visualization or TSVB (time-series visual builder).

**TBD**


