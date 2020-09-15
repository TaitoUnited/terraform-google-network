# Google Cloud network

Example usage:

```
provider "google" {
  project = "my-infrastructure"
  region  = "europe-west1"
  zone    = "europe-west1b"
}

resource "google_project_service" "compute" {
  service                    = "compute.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "servicenetworking" {
  service                    = "servicenetworking.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

module "network" {
  source       = "TaitoUnited/network/google"
  version      = "1.0.0"
  providers    = [ google ]
  depends_on   = [
    google_project_service.compute,
    google_project_service.servicenetworking
  ]

  network      = yamldecode(file("${path.root}/../infra.yaml"))["network"]
}
```

Example YAML:

```
network:
  name: my-network
  region: europe-west1
  natEnabled: true # NAT is required for private Kubernetes or virtual machines
  privateGoogleServicesEnabled: true
```

Combine with the following modules to get a complete infrastructure defined by YAML:

- [Admin](https://registry.terraform.io/modules/TaitoUnited/admin/google)
- [DNS](https://registry.terraform.io/modules/TaitoUnited/dns/google)
- [Network](https://registry.terraform.io/modules/TaitoUnited/network/google)
- [Kubernetes](https://registry.terraform.io/modules/TaitoUnited/kubernetes/google)
- [Databases](https://registry.terraform.io/modules/TaitoUnited/databases/google)
- [Storage](https://registry.terraform.io/modules/TaitoUnited/storage/google)
- [Monitoring](https://registry.terraform.io/modules/TaitoUnited/monitoring/google)
- [PostgreSQL privileges](https://registry.terraform.io/modules/TaitoUnited/postgresql-privileges/google)
- [MySQL privileges](https://registry.terraform.io/modules/TaitoUnited/mysql-privileges/google)

TIP: Similar modules are also available for AWS, Azure, and DigitalOcean. All modules are used by [infrastructure templates](https://taitounited.github.io/taito-cli/templates#infrastructure-templates) of [Taito CLI](https://taitounited.github.io/taito-cli/).

See also [Google Cloud project resources](https://registry.terraform.io/modules/TaitoUnited/project-resources/google), [Full Stack Helm Chart](https://github.com/TaitoUnited/taito-charts/blob/master/full-stack), and [full-stack-template](https://github.com/TaitoUnited/full-stack-template).

Contributions are welcome!