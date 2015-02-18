# ansible-elasticsearch

An Ansible role for installing [ElasticSearch](http://www.elasticsearch.org/).

## Role Variables

- `elasticsearch_version` - Kibana version to install (default: `1.4.0`)
- `elasticsearch_cluster_name` - ElasticSearch cluster name (default: `elasticsearch`)
- `elasticsearch_bind_host` - Address ElasticSearch binds to (default: `0.0.0.0`)
- `elasticsearch_tcp_port` - TCP port ElasticSearch binds to (default: `9300`)
- `elasticsearch_http_port` - HTTP port ElasticSearch binds to (default: `9200`)

## Example Playbook

See the [examples](./examples/) directory.
