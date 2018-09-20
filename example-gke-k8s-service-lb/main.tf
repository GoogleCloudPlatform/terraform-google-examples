variable "region" {
  default = "us-west1"
}

variable "zone" {
  default = "us-west1-b"
}

variable "network_name" {
  default = "tf-gke-k8s"
}

provider "google" {
  region = "${var.region}"
}

resource "google_compute_network" "default" {
  name                    = "${var.network_name}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name                     = "${var.network_name}"
  ip_cidr_range            = "10.127.0.0/20"
  network                  = "${google_compute_network.default.self_link}"
  region                   = "${var.region}"
  private_ip_google_access = true
}

data "google_client_config" "current" {}

data "google_container_engine_versions" "default" {
  zone = "${var.zone}"
}

resource "google_container_cluster" "default" {
  name               = "${var.network_name}"
  zone               = "${var.zone}"
  initial_node_count = 3
  min_master_version = "${data.google_container_engine_versions.default.latest_master_version}"
  network            = "${google_compute_subnetwork.default.name}"
  subnetwork         = "${google_compute_subnetwork.default.name}"

  // Use legacy ABAC until these issues are resolved: 
  //   https://github.com/mcuadros/terraform-provider-helm/issues/56
  //   https://github.com/terraform-providers/terraform-provider-kubernetes/pull/73
  enable_legacy_abac = true

  // Wait for the GCE LB controller to cleanup the resources.
  provisioner "local-exec" {
    when    = "destroy"
    command = "sleep 90"
  }
}

output network {
  value = "${google_compute_subnetwork.default.network}"
}

output subnetwork_name {
  value = "${google_compute_subnetwork.default.name}"
}

output cluster_name {
  value = "${google_container_cluster.default.name}"
}

output cluster_region {
  value = "${var.region}"
}

output cluster_zone {
  value = "${google_container_cluster.default.zone}"
}
