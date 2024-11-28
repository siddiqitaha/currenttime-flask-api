# Resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# AKS cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = "currenttime-aks-cluster"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "currenttime-aks"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.main.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
}

# Flask API Deployment
resource "kubernetes_deployment" "app" {
  metadata {
    name = "currenttime-flask-api"
    labels = {
      app = "currenttime-flask-api"
    }
  }

  spec {
    replicas = 2

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = 1
        max_unavailable = 0
      }
    }

    selector {
      match_labels = {
        app = "currenttime-flask-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "currenttime-flask-api"
        }
      }

      spec {
        security_context {
          run_as_non_root = true
          run_as_user     = 1000
          fs_group        = 2000
        }

        container {
          image = "siddiqitaha/currenttime-flask-api:1.2v"
          name  = "currenttime-flask-api"
          
          port {
            container_port = 8080
            name          = "http"
          }

          resources {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = "http"
            }
            initial_delay_seconds = 30
            period_seconds       = 10
            timeout_seconds     = 5
            failure_threshold   = 3
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds       = 5
          }
        }
      }
    }
  }
}

# Flask API Service
resource "kubernetes_service" "app" {
  metadata {
    name = "currenttime-flask-api-service"
    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = "80"
      "prometheus.io/path"   = "/metrics"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.app.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 8080
      name        = "http"
    }
    type = "LoadBalancer"
  }
}

# Horizontal Pod Autoscaler
resource "kubernetes_horizontal_pod_autoscaler_v2" "app" {
  metadata {
    name = "currenttime-flask-api-hpa"
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.app.metadata[0].name
    }

    min_replicas = 2
    max_replicas = 5

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 80
        }
      }
    }
  }
}

# Network Policy
resource "kubernetes_network_policy" "app" {
  metadata {
    name = "currenttime-flask-api-network-policy"
  }

  spec {
    pod_selector {
      match_labels = {
        app = kubernetes_deployment.app.metadata[0].labels.app
      }
    }

    policy_types = ["Ingress", "Egress"]

    ingress {
      ports {
        port = 80
        protocol = "TCP"
      }
    }
  }
}

# Output the cluster's kubeconfig
output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}

# Output the public IP of the LoadBalancer service
output "load_balancer_ip" {
  value = kubernetes_service.app.status.0.load_balancer.0.ingress.0.ip
}