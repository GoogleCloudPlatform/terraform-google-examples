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
 
variable service_port {
  default = "30000"
}

variable service_port_name {
  default = "http"
}

variable target_tags {
  default = "gke-dev"
}

variable backend {}

resource "random_id" "assets-bucket" {
  prefix      = "terraform-static-content-"
  byte_length = 2
}

variable region {
  default = "us-central1"
}

provider google {
  region = "${var.region}"
}

module "gce-lb-http" {
  source        = "github.com/GoogleCloudPlatform/terraform-google-lb-http"
  name          = "group-http-lb"
  ssl           = true
  private_key   = "${tls_private_key.example.private_key_pem}"
  certificate   = "${tls_self_signed_cert.example.cert_pem}"

  // Make sure when you create the cluster that you provide the `--tags` argument to add the appropriate `target_tags` referenced in the http module. 
  target_tags = ["${var.target_tags}"]

  // Use custom url map.
  url_map        = "${google_compute_url_map.my-url-map.self_link}"
  create_url_map = false

  // Get selfLink URLs for the actual instance groups (not the manager) of the existing GKE cluster:
  //   gcloud compute instance-groups list --uri
  backends = {
    "0" = [
      {
        # Each node pool instance group should be added to the backend.
        group = "${var.backend}"
      },
    ]
  }

  // You also must add the named port on the existing GKE clusters instance group that correspond to the `service_port` and `service_port_name` referenced in the module definition.
  //   gcloud compute instance-groups set-named-ports INSTANCE_GROUP_NAME --named-ports=NAME:PORT
  // replace `INSTANCE_GROUP_NAME` with the name of your GKE cluster's instance group and `NAME` and `PORT` with the values of `service_port_name` and `service_port` respectively.
  backend_params = [
    // health check path, port name, port number, timeout seconds.
    "/,${var.service_port_name},${var.service_port},10",
  ]
}

resource "google_compute_url_map" "my-url-map" {
  // note that this is the name of the load balancer
  name            = "my-url-map"
  default_service = "${module.gce-lb-http.backend_services[0]}"

  host_rule = {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher = {
    name            = "allpaths"
    default_service = "${module.gce-lb-http.backend_services[0]}"

    path_rule {
      paths   = ["/assets", "/assets/*"]
      service = "${google_compute_backend_bucket.assets.self_link}"
    }
  }
}

resource "google_compute_backend_bucket" "assets" {
  name        = "${random_id.assets-bucket.hex}"
  description = "Contains static resources for example app"
  bucket_name = "${google_storage_bucket.assets.name}"
  enable_cdn  = true
}

resource "google_storage_bucket" "assets" {
  name     = "${random_id.assets-bucket.hex}"
  location = "US"

  // delete bucket and contents on destroy.
  force_destroy = true
}

// The image object in Cloud Storage.
// Note that the path in the bucket matches the paths in the url map path rule above.
resource "google_storage_bucket_object" "image" {
  name         = "assets/gcp-logo.svg"
  content      = "${file("gcp-logo.svg")}"
  content_type = "image/svg+xml"
  bucket       = "${google_storage_bucket.assets.name}"
}

// Make object public readable.
resource "google_storage_object_acl" "image-acl" {
  bucket         = "${google_storage_bucket.assets.name}"
  object         = "${google_storage_bucket_object.image.name}"
  predefined_acl = "publicread"
}
