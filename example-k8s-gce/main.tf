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
 
variable region {
  default = "us-central1"
}

variable zone {
  default = "us-central1-b"
}

provider google {
  region = "${var.region}"
}

variable num_nodes {
  default = 3
}

variable cluster_name {
  default = "dev"
}

module "k8s" {
  source        = "github.com/danisla/terraform-google-k8s-gce"
  name          = "${var.cluster_name}"
  network       = "default"
  region        = "${var.region}"
  zone          = "${var.zone}"
  k8s_version   = "1.7.3"
  access_config = []
  add_tags      = ["nat-us-central1"]
  num_nodes     = "${var.num_nodes}"
  depends_id    = "${join(",", list(module.nat.depends_id, null_resource.route_cleanup.id))}"
}

module "nat" {
  source  = "github.com/danisla/terraform-google-nat-gateway"
  region  = "${var.region}"
  zone    = "${var.zone}"
  network = "default"
}

resource "null_resource" "route_cleanup" {
  // Cleanup the routes after the managed instance groups have been deleted.
  provisioner "local-exec" {
    when    = "destroy"
    command = "gcloud compute routes list --filter='name~k8s-${var.cluster_name}.*' --format='get(name)' | tr '\n' ' ' | xargs -I {} sh -c 'echo Y|gcloud compute routes delete {}' || true"
  }
}
