# Google Cloud network

Example usage:

```
provider "google" {
  project      = "my-infrastructure"
  region       = "europe-west1"
  zone         = "europe-west1-b"
}

resource "google_project_service" "compute" {
  service      = "compute.googleapis.com"
}

resource "google_project_service" "servicenetworking" {
  service      = "servicenetworking.googleapis.com"
}

module "network" {
  source       = "TaitoUnited/network/google"
  version      = "2.1.0"
  providers    = [ google ]
  depends_on   = [
    google_project_service.compute,
    google_project_service.servicenetworking
  ]

  project_id   = "my-infrastructure"
  network      = yamldecode(file("${path.root}/../infra.yaml"))["network"]
}
```

Example YAML:

```
# See: https://registry.terraform.io/modules/TaitoUnited/network/google

network:
  name: my-network
  region: europe-west1
  dnsLoggingEnabled: true
  natEnabled: true # NAT is required for private Kubernetes or virtual machines
  privateGoogleServicesEnabled: true
  vpcSharingEnabled: false
  sharedVpcServiceProjects:
    - another-project

  subnets:
    - subnet_name: my-network-dmz
      subnet_ip: 10.0.0.0/24
      subnet_region: europe-west1
      subnet_private_access: true
      subnet_flow_logs: true
    - subnet_name: my-network-eu-west1
      subnet_ip: 10.0.32.0/19
      subnet_region: europe-west1
      subnet_private_access: true
      subnet_flow_logs: false
    - subnet_name: my-network-eu-west4
      subnet_ip: 10.0.64.0/19
      subnet_region: europe-west1
      subnet_private_access: true
      subnet_flow_logs: false

  secondary_ranges:
    my-network-eu-west1:
      - range_name: my-network-eu-west1-pods
        ip_cidr_range: 192.168.0.0/19
      - range_name: my-network-eu-west1-services
        ip_cidr_range: 192.168.32.0/19
    my-network-eu-west4:
      - range_name: my-network-eu-west4-pods
        ip_cidr_range: 192.168.64.0/19
      - range_name: my-network-eu-west4-services
        ip_cidr_range: 192.168.96.0/19
```

Combine with the following modules to get a complete infrastructure defined by YAML:

- [Admin](https://registry.terraform.io/modules/TaitoUnited/admin/google)
- [DNS](https://registry.terraform.io/modules/TaitoUnited/dns/google)
- [Network](https://registry.terraform.io/modules/TaitoUnited/network/google)
- [Compute](https://registry.terraform.io/modules/TaitoUnited/compute/google)
- [Kubernetes](https://registry.terraform.io/modules/TaitoUnited/kubernetes/google)
- [Databases](https://registry.terraform.io/modules/TaitoUnited/databases/google)
- [Storage](https://registry.terraform.io/modules/TaitoUnited/storage/google)
- [Monitoring](https://registry.terraform.io/modules/TaitoUnited/monitoring/google)
- [Integrations](https://registry.terraform.io/modules/TaitoUnited/integrations/google)
- [PostgreSQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/postgresql)
- [MySQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/mysql)

TIP: Similar modules are also available for AWS, Azure, and DigitalOcean. All modules are used by [infrastructure templates](https://taitounited.github.io/taito-cli/templates#infrastructure-templates) of [Taito CLI](https://taitounited.github.io/taito-cli/). See also [Google Cloud project resources](https://registry.terraform.io/modules/TaitoUnited/project-resources/google), [Full Stack Helm Chart](https://github.com/TaitoUnited/taito-charts/blob/master/full-stack), and [full-stack-template](https://github.com/TaitoUnited/full-stack-template).

Contributions are welcome!
