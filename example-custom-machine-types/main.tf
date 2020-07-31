provider "google" {
  region = var.region
  project = var.project
}

data "google_project" "current" {}

data "google_compute_default_service_account" "default" {}

// GCP Virtual Private Cloud (VPC)
resource "google_compute_network" "default" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

// Subnet
resource "google_compute_subnetwork" "default" {
  name                     = var.network_name
  ip_cidr_range            = var.network_cidr
  network                  = google_compute_network.default.self_link
  region                   = var.region
  private_ip_google_access = true
}

// VM Instance: Google Compute Engine
resource "google_compute_instance" "default" {
  count                     = var.num_nodes
  name                      = "${var.name}-${count.index + 1}"
  zone                      = var.zone
  tags                      = concat(list("${var.name}-ssh", "${var.name}"), var.node_tags)
  machine_type              = var.machine_type
  min_cpu_platform          = var.min_cpu_platform
  allow_stopping_for_update = true

  boot_disk {
    auto_delete = var.disk_auto_delete

    initialize_params {
      image = "${var.image_project}/${var.image_family}"
      size  = var.disk_size_gb
      type  = var.disk_type
    }
  }

  network_interface {
    subnetwork    = google_compute_subnetwork.default.name
    network_ip       = var.network_ip
  }

  metadata = merge(map("startup-script", var.startup_script, "tf_depends_id", var.depends_id),
    var.metadata
  )

  service_account {
    email  = var.service_account_email == "" ? data.google_compute_default_service_account.default.email : var.service_account_email
    scopes = var.service_account_scopes
  }
}

// Firewall rules
resource "google_compute_firewall" "ssh" {
  name    = "${var.name}-ssh"
  network = google_compute_subnetwork.default.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["${var.name}-bastion"]
  target_tags = ["${var.name}-ssh"]
}

// Bastion host image
data "google_compute_image" "bastion" {
  family  = var.bastion_image_family
  project = var.bastion_image_project == "" ? data.google_project.current.project_id : var.bastion_image_project
}

// Bastion host instance
module "bastion" {
  source            = "terraform-google-modules/bastion-host/google"
  version           = "2.7.0"
  project           = var.project
  subnet            = google_compute_subnetwork.default.self_link    
  zone              = var.zone
  network           = google_compute_subnetwork.default.name
  machine_type      = var.bastion_machine_type
  name              = "${var.name}-bastion"
}

// Cloud NAT for external internet routing
module "cloud-nat" {
  source            = "terraform-google-modules/cloud-nat/google"
  version           = "1.3.0"
  project_id        = var.project
  region            = var.region
  router            = "router1"
  network           = google_compute_network.default.self_link
  create_router     = true
}

// OUTPUT: host name of the Bastion host
output "bastion_instance" {
  value = module.bastion.hostname
}

// OUTPUT: Command to connect to bastion host
output "bastion" {
  value = "gcloud compute ssh --ssh-flag=\"-A\" $(terraform output bastion_instance)"
}