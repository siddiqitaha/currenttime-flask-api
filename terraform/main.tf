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
    node_count = 1 
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

# Kubernetes deployment
resource "kubernetes_deployment" "app" {
  metadata {
    name = "currenttime-flask-api"
    labels = {
      app = "currenttime-flask-api"
    }
  }

  spec {
    replicas = 2  # Matching your existing deployment

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
        container {
          image = "siddiqitaha/currenttime-flask-api:latest"
          name  = "currenttime-flask-api"
          
          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

# Kubernetes service
resource "kubernetes_service" "app" {
  metadata {
    name = "currenttime-flask-api-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment.app.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
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