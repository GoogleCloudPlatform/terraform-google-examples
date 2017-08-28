/*
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
variable gke_master_ip {
  description = "The IP address of the GKE master"
}

variable gke_node_tag {
  description = "The network tag for the gke nodes"
}

variable region {
  default = "us-central1"
}

variable zone {
  default = "us-central1-f"
}

variable network {
  default = "default"
}

provider google {
  region = "${var.region}"
}

module "nat" {
  source  = "github.com/GoogleCloudPlatform/terraform-google-nat-gateway"
  region  = "${var.region}"
  zone    = "${var.zone}"
  tags    = ["${var.gke_node_tag}"]
  network = "${var.network}"
}

// Route so that traffic to the master goes through the default gateway.
// This fixes things like kubectl exec and logs
resource "google_compute_route" "gke-master-default-gw" {
  name             = "gke-master-default-gw"
  dest_range       = "${var.gke_master_ip}"
  network          = "${var.network}"
  next_hop_gateway = "default-internet-gateway"
  tags             = ["${var.gke_node_tag}"]
  priority         = 700
}
