cluster_name = "<CLUSTER_NAME>"
max_lease_ttl = "768h"
default_lease_ttl = "768h"

disable_clustering = "True"
cluster_addr = "http://<SERVER_IP>:8201"
api_addr = "http://<SERVER_IP>:8200"
disable_mlock = "True"

listener "tcp" {
  address = "<SERVER_IP>:8200"
  cluster_address = "<SERVER_IP>:8201"
  tls_disable = "true"
}

backend "consul" {
  address = "<SERVER_IP>:8500"
  path = "vault"
  service = "vault"
    scheme = "http"
  }
ui = true
