job "monitoring" {
  affinity {
    attribute = "${unique.hostname}"
    value = "<SERVER_HOSTNAME>.<LOCAL_DOMAIN>"
    weight = 100
  }
  datacenters = ["<DATACENTRE_NAME>"]
  type = "service"
  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    progress_deadline = "10m"
    auto_revert = false
    canary = 0
  }
  migrate {
    max_parallel = 1
    health_check = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }
  group "monitoring" {
    count = 1
    restart {
      attempts = 5
      interval = "5m"
      delay = "15s"
      mode = "delay"
    }
    ephemeral_disk {
      size = 400
    }
    network {
      port "unifipoller" {
          to = 9130
      }
      port "grafana" {
          to = 3000
      }
      port "loki" {
          to = 3100
      }
      port "prometheus" {
        to = 9090
      }
      port "speedtest2prom" {
        to = 9516
      }
    }
    task "unifiPoller" {
      driver = "docker"
      config {
        image = "golift/unifi-poller:latest"
        dns_servers = ["<SERVER_IP>"]
        network_mode = "bridge"
        volumes = [
            "/media/unifipoller/config:/etc/unifi-poller:Z",
            "/etc/localtime:/etc/localtime:ro"
        ]
        ports = ["unifipoller"]
      }
      resources {
        cpu    = 251 # 500 MHz
        memory = 256 # 4G
      }
      service {
        name = "unifipoller"
        tags = [
            "unifipoller",
            "monitoring"
            ]
        port = "unifipoller"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    task "grafana" {
      env = {
        discovery.type = "single-node"
        GF_INSTALL_PLUGINS = "grafana-worldmap-panel,grafana-clock-panel,grafana-piechart-panel,natel-discrete-panel,mtanda-histogram-panel,larona-epict-panel"
      }
      driver = "docker"
      config {
        dns_servers = ["<SERVER_IP>"]
        image = "grafana/grafana:latest"
        network_mode = "bridge"
        volumes = [
            "/media/grafana/config:/etc/grafana:Z",
            "/media/grafana/home:/var/lib/grafana:Z",
            "/etc/localtime:/etc/localtime:ro"
        ]
        ports = ["grafana"]
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 512 # 4G
      }
      service {
        name = "grafana"
        tags = [
            "grafana",
            "monitoring"
            ]
        port = "grafana"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    task "loki" {
      env {
        discovery.type = "single-node"
      }
      driver = "docker"
      config {
        dns_servers = ["<SERVER_IP>"]
        image = "grafana/loki:2.0.0"
        network_mode = "bridge"
        volumes = [
            "/media/loki/data:/tmp/loki:Z",
            "/media/loki/config:/etc/loki:Z",
            "/etc/localtime:/etc/localtime:ro"
        ]
        ports = ["loki"]
      }
      resources {
        cpu    = 1000 # 500 MHz
        memory = 2048 # 4G
      }
      service {
        name = "loki"
        tags = [
            "loki"
        ]
        port = "loki"
        check {
          name     = "loki HTTPS"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    task "prometheus" {
      driver = "docker"
      config {
        dns_servers = ["<SERVER_IP>"]
        image = "prom/prometheus"
        network_mode = "bridge"
        volumes = [
            "/media/prometheus/data:/prometheus:Z",
            "/media/prometheus/config:/etc/prometheus:Z",
            "/etc/localtime:/etc/localtime:ro"
        ]
        ports = ["prometheus"]
      }
      resources {
        cpu    = 1000 # 500 MHz
        memory = 2048 # 4G
      }
      service {
        name = "prometheus"
        tags = [
            "prometheus",
        ]
        port = "prometheus"
        check {
          name     = "prometheus HTTPS"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    task "speedtest2prometheus" {
      driver = "docker"
      config {
        dns_servers = ["<SERVER_IP>"]
        image = "jraviles/prometheus_speedtest:latest"
        network_mode = "bridge"
        volumes = [
            "/etc/localtime:/etc/localtime:ro"
        ]
        ports = ["speedtest2prom"]
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 512 # 512M
      }
      service {
        name = "speedtest2prom"
        tags = [
            "speedtest"
        ]
        port = "speedtest2prom"
        check {
          name     = "Speedtest exporter for Prometheus"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
