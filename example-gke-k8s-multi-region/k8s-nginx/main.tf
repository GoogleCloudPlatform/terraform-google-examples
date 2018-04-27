variable "external_ip" {}
variable "node_port" {}

resource "kubernetes_service" "nginx" {
  metadata {
    namespace = "default"
    name      = "nginx"
  }

  spec {
    type             = "NodePort"
    session_affinity = "ClientIP"
    external_ips     = ["${var.external_ip}"]

    selector {
      run = "nginx"
    }

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = 80
      node_port   = "${var.node_port}"
    }
  }
}

resource "kubernetes_replication_controller" "nginx" {
  metadata {
    name      = "nginx"
    namespace = "default"

    labels {
      run = "nginx"
    }
  }

  spec {
    selector {
      run = "nginx"
    }

    template {
      container {
        image = "nginx:latest"
        name  = "nginx"

        resources {
          limits {
            cpu    = "0.5"
            memory = "512Mi"
          }

          requests {
            cpu    = "250m"
            memory = "50Mi"
          }
        }
      }
    }
  }
}
