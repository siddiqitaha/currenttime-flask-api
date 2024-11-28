output "grafana_ip" {
  value = kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].ip
}

output "prometheus_cluster_ip" {
  value = kubernetes_service.prometheus.spec[0].cluster_ip
}

output "prometheus_url" {
  description = "URL for Prometheus UI"
  value = try(
    "http://${kubernetes_service.prometheus.status[0].load_balancer[0].ingress[0].ip}:9090",
    "Waiting for Prometheus LoadBalancer IP..."
  )
}

output "grafana_url" {
  description = "URL for Grafana UI"
  value = try(
    "http://${kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].ip}",
    "Waiting for Grafana LoadBalancer IP..."
  )
}