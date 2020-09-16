/**
 * Copyright 2020 Taito United
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  network                = var.network

  network_name           = "${local.network.name}-network"
  subnet_name            = "${local.network.name}-subnet"
  pods_ip_range_name     = "${local.network.name}-ip-range-pods"
  services_ip_range_name = "${local.network.name}-ip-range-svc"
}

data "google_project" "project" {
}
