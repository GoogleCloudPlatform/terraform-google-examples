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
 
data "template_file" "group1-startup-script" {
  template = "${file("${format("%s/../scripts/nginx_upstream.sh.tpl", path.module)}")}"

  vars {
    UPSTREAM = "${module.gce-ilb.ip_address}"
  }
}

data "template_file" "group2-startup-script" {
  template = "${file("${format("%s/../scripts/gceme.sh.tpl", path.module)}")}"

  vars {
    PROXY_PATH = ""
  }
}

data "template_file" "group3-startup-script" {
  template = "${file("${format("%s/../scripts/gceme.sh.tpl", path.module)}")}"

  vars {
    PROXY_PATH = ""
  }
}

module "mig1" {
  source            = "github.com/GoogleCloudPlatform/terraform-google-managed-instance-group"
  region            = "${var.region}"
  zone              = "${var.zone}"
  name              = "group1"
  size              = 2
  target_tags       = ["allow-group1"]
  target_pools      = ["${module.gce-lb-fr.target_pool}"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group1-startup-script.rendered}"
}

module "mig2" {
  source            = "github.com/GoogleCloudPlatform/terraform-google-managed-instance-group"
  region            = "${var.region}"
  zone              = "us-central1-c"
  name              = "group2"
  size              = 2
  target_tags       = ["allow-group2"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group2-startup-script.rendered}"
}

module "mig3" {
  source            = "github.com/GoogleCloudPlatform/terraform-google-managed-instance-group"
  region            = "${var.region}"
  zone              = "us-central1-f"
  name              = "group3"
  size              = 2
  target_tags       = ["allow-group3"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group3-startup-script.rendered}"
}
