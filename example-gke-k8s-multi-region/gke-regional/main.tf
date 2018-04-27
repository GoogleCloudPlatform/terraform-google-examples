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

data "google_compute_zones" "default" {
  region = "${var.region}"
}

data "google_container_engine_versions" "default" {
  zone = "${element(data.google_compute_zones.default.names, 0)}"
}

resource "google_container_cluster" "default" {
  name               = "${var.cluster_name}"
  region             = "${var.region}"
  initial_node_count = "${var.node_count}"
  min_master_version = "${var.master_version != "" ? var.master_version : data.google_container_engine_versions.default.latest_node_version}"
  network            = "${var.network}"
  subnetwork         = "${var.subnetwork}"

  master_auth {
    username = "${var.gke_username}"
    password = "${var.gke_password}"
  }

  node_config {
    tags = ["${var.tags}"]
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
