# container/eks/tool/tracing/jaeger

Provisions a tracing toolstack based on Jaeger with ElasticSearch as database.

The actual type of ElasticSearch database to use is controlled via variable `elasticsearch_strategy`:

* `ES_INTERNAL`: elasticsearch is provisioned via the elasticsearch dependency of the jaeger helm chart, which creates an elasticsearch 7.x cluster of 3 nodes using no security (no TLS, no authentication) 
* `ES_ECK_OPERATOR`: elasticsearch is provisioned via the elasticsearch cloud for kubernetes operator, which creates an elasticsearch 8.x cluster of 1 node using security (TLS, authentication)

Currently, only option `ES_INTERNAL` is actually working since Jaeger does not support ElasticSearch version 8.+ properly.

## TODOs
