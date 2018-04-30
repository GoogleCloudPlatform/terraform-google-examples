variable "region" {
  default = "us-west1"
}

variable "cluster_name" {
  default = "tf-regional"
}

variable "gke_username" {}
variable "gke_password" {}

variable "master_version" {
  default = ""
}

variable "node_count" {
  default = 1
}

variable "tags" {
  type    = "list"
  default = []
}

variable "network" {
  default = "default"
}

variable "subnetwork" {
  default = "default"
}

// External data source to fetch latest regional versions (beta).
data "external" "container-regional-versions-beta" {
  program = ["${path.module}/get_server_config_beta.sh"]

  query = {
    region = "${var.region}"
  }
}

resource "google_container_cluster" "default" {
  name               = "${var.cluster_name}"
  region             = "${var.region}"
  initial_node_count = "${var.node_count}"
  min_master_version = "${var.master_version != "" ? var.master_version : data.external.container-regional-versions-beta.result.latest_master_version}"
  network            = "${var.network}"
  subnetwork         = "${var.subnetwork}"

  master_auth {
    username = "${var.gke_username}"
    password = "${var.gke_password}"
  }

  node_config {
    tags = ["${var.tags}"]
  }

  // Wait for the GCE LB controller to cleanup the resources.
  provisioner "local-exec" {
    when    = "destroy"
    command = "sleep 90"
  }
}

output "instance_groups" {
  value = "${google_container_cluster.default.instance_group_urls}"
}

output "endpoint" {
  value = "${google_container_cluster.default.endpoint}"
}

output "client_certificate" {
  value = "${google_container_cluster.default.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.default.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.default.master_auth.0.cluster_ca_certificate}"
}
