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

variable network {
  default = "default"
}

variable zone {
  default = "us-central1-b"
}

provider google {
  region = "${var.region}"
}

resource "random_id" "name" {
  byte_length = 2
}

module "mysql-db" {
  source           = "github.com/GoogleCloudPlatform/terraform-google-sql-db"
  name             = "example-mysql-${random_id.name.hex}"
  database_version = "MYSQL_5_6"
}

module "postgresql-db" {
  source           = "github.com/GoogleCloudPlatform/terraform-google-sql-db"
  name             = "example-postgresql-${random_id.name.hex}"
  user_host        = ""
  database_version = "POSTGRES_9_6"
}
