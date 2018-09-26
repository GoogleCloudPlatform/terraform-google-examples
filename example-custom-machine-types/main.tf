provider "google" {
  region = "${var.region}"
}

data "google_project" "current" {}

data "google_compute_default_service_account" "default" {}

resource "google_compute_network" "default" {
  name                    = "${var.network_name}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name                     = "${var.network_name}"
  ip_cidr_range            = "${var.network_cidr}"
  network                  = "${google_compute_network.default.self_link}"
  region                   = "${var.region}"
  private_ip_google_access = true
}

resource "google_compute_instance" "default" {
  count                     = "${var.num_nodes}"
  name                      = "${var.name}-${count.index + 1}"
  zone                      = "${var.zone}"
  tags                      = ["${concat(list("${var.name}-ssh", "${var.name}"), var.node_tags)}"]
  machine_type              = "${var.machine_type}"
  min_cpu_platform          = "${var.min_cpu_platform}"
  allow_stopping_for_update = true

  boot_disk {
    auto_delete = "${var.disk_auto_delete}"

    initialize_params {
      image = "${var.image_project}/${var.image_family}"
      size  = "${var.disk_size_gb}"
      type  = "${var.disk_type}"
    }
  }

  network_interface {
    subnetwork    = "${google_compute_subnetwork.default.name}"
    access_config = ["${var.access_config}"]
    address       = "${var.network_ip}"
  }

  metadata = "${merge(
    map("startup-script", "${var.startup_script}", "tf_depends_id", "${var.depends_id}"),
    var.metadata
  )}"

  service_account {
    email  = "${var.service_account_email == "" ? data.google_compute_default_service_account.default.email : var.service_account_email }"
    scopes = ["${var.service_account_scopes}"]
  }
}

resource "google_compute_firewall" "ssh" {
  name    = "${var.name}-ssh"
  network = "${google_compute_subnetwork.default.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["${var.name}-bastion"]
  target_tags = ["${var.name}-ssh"]
}

// Bastion host
data "google_compute_image" "bastion" {
  family  = "${var.bastion_image_family}"
  project = "${var.bastion_image_project == "" ? data.google_project.current.project_id : var.bastion_image_project}"
}

module "bastion" {
  source             = "GoogleCloudPlatform/managed-instance-group/google"
  version            = "1.1.14"
  region             = "${var.region}"
  zone               = "${var.zone}"
  network            = "${google_compute_subnetwork.default.name}"
  subnetwork         = "${google_compute_subnetwork.default.name}"
  target_tags        = ["${var.name}-bastion"]
  machine_type       = "${var.bastion_machine_type}"
  name               = "${var.name}-bastion"
  compute_image      = "${data.google_compute_image.bastion.self_link}"
  http_health_check  = false
  service_port       = "80"
  service_port_name  = "http"
  wait_for_instances = true
}

// NAT gateway
module "nat-gateway" {
  source     = "GoogleCloudPlatform/nat-gateway/google"
  version    = "1.2.0"
  region     = "${var.region}"
  zone       = "${var.zone}"
  network    = "${google_compute_subnetwork.default.name}"
  subnetwork = "${google_compute_subnetwork.default.name}"
  tags       = ["${var.name}"]
}

output "bastion_instance" {
  value = "${element(module.bastion.instances[0], 0)}"
}

output "bastion" {
  value = "gcloud compute ssh --ssh-flag=\"-A\" $(terraform output bastion_instance)"
}
