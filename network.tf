/**
 * Copyright 2021 Taito United
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

module "network" {
  source                    = "terraform-google-modules/network/google"
  version                   = "~> 2.5.0"

  project_id                = var.project_id
  network_name              = local.network_name
  shared_vpc_host           = local.network.vpcSharingEnabled

  subnets = [
    {
      subnet_name           = local.subnet_name
      subnet_ip             = "10.0.0.0/17"
      subnet_region         = local.network.region
      subnet_private_access = local.network.privateGoogleServicesEnabled
      subnet_flow_logs      = local.network.flowLoggingEnabled
    },
  ]

  secondary_ranges = {
    "${local.subnet_name}" = [
      {
        range_name    = local.pods_ip_range_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = local.services_ip_range_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }

  # TODO: prevent destroy -> https://github.com/hashicorp/terraform/issues/18367
}

# Provide network name only after network has been created
# TODO: Is this still required or can it be replaced with
# 'module.network.network_self_link'?
# data "external" "network_wait" {
#   depends_on = [
#     module.network,
#     google_service_networking_connection.private_vpc_connection
#   ]
#
#   program = ["sh", "-c", "sleep 15; echo '{ \"network_name\": \"${module.network.network_name}\", \"network_self_link\": \"${module.network.network_self_link}\" }'"]
# }

/* NAT */

resource "google_compute_router" "nat_router" {
  count   = coalesce(local.network.natEnabled, false) ? 1 : 0

  name    = "nat-router"
  region  = local.network.region
  network = module.network.network_name
  bgp {
    asn = 64514
  }
}

module "cloud-nat" {
  count      = coalesce(local.network.natEnabled, false) ? 1 : 0

  source     = "terraform-google-modules/cloud-nat/google"
  version    = "~> 1.3"
  project_id = var.project_id
  region     = local.network.region
  router     = google_compute_router.nat_router[0].name
}

/* Private peering network for accessing Google services (Cloud SQL, etc.) */

resource "google_compute_global_address" "private_ip_address" {
  count         = local.network.privateGoogleServicesEnabled ? 1 : 0

  project       = var.project_id
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.network.network_self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  count         = local.network.privateGoogleServicesEnabled ? 1 : 0

  network                 = module.network.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address[0].name]
}

/* Shared vpc service projects */

resource "google_compute_shared_vpc_service_project" "service1" {
  for_each        = {for item in local.network.sharedVpcServiceProjects: item => item}
  host_project    = var.project_id
  service_project = each.value
}
