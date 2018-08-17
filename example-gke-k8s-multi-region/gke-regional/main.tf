variable "region" {
  default = "us-west1"
}

variable "cluster_name" {
  default = "tf-regional"
}

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

data "google_compute_zones" "available" {
  region = "${var.region}"
}

data "google_container_engine_versions" "default" {
  zone = "${element(data.google_compute_zones.available.names, 0)}"
}

resource "google_container_cluster" "default" {
  name               = "${var.cluster_name}"
  region             = "${var.region}"
  initial_node_count = "${var.node_count}"
  min_master_version = "${var.master_version != "" ? var.master_version : data.google_container_engine_versions.default.latest_master_version}"
  network            = "${var.network}"
  subnetwork         = "${var.subnetwork}"

  // Use legacy ABAC until these issues are resolved: 
  //   https://github.com/mcuadros/terraform-provider-helm/issues/56
  //   https://github.com/terraform-providers/terraform-provider-kubernetes/pull/73
  enable_legacy_abac = true

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
