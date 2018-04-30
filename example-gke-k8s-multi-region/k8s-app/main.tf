variable "external_ip" {}
variable "node_port" {}

resource "kubernetes_service" "default" {
  metadata {
    namespace = "default"
    name      = "example"
  }

  spec {
    type             = "NodePort"
    session_affinity = "ClientIP"
    external_ips     = ["${var.external_ip}"]

    selector {
      run = "example"
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

resource "kubernetes_config_map" "default" {
  metadata {
    name = "example"
  }

  data {
    index.php = "${file("${format("%s/index.php", path.module)}")}"
  }
}

resource "kubernetes_replication_controller" "default" {
  metadata {
    name      = "example"
    namespace = "default"

    labels {
      run = "example"
    }
  }

  spec {
    selector {
      run = "example"
    }

    template {
      container {
        image = "php:alpine"
        name  = "example"

        command = [
          "php",
          "-S",
          "0.0.0.0:80",
          "-t",
          "/var/www",
        ]

        volume_mount = {
          name       = "data"
          mount_path = "/var/www/"
        }

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

      volume = {
        name = "data"

        config_map = {
          name = "example"
        }
      }
    }
  }
}
