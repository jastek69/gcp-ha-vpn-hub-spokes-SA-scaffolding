# Scaffolding Guide
This is a quick, repeatable pattern when adding a new project (e.g., atlantis-ops) and append its keys in the right places.

## Add variables

### bootstrap/02-variables-boot.tf: Add
- variable "atlantis_project", "atlantis_region", "atlantis_zone"
- variable "atlantis_sa"
- infra/02-variables-infra.tf: Add the same 4 variables

## Providers

### bootstrap/01-providers.tf: Add a provider alias block
- alias = "atlantis-ops", project = var.atlantis_project, region = var.atlantis_region, impersonate = local.spoke_sa_by_project_id[var.atlantis_project]
- infra/01-providers-infra.tf: Add the same alias block
- alias = "atlantis-ops", project/region same as above, impersonate same pattern

## Locals

### bootstrap/03a-locals-bootstrap.tf: Append entries
- project_ids: atlantis-ops = var.atlantis_project
- spoke_sas merge block: atlantis-ops = var.atlantis_sa
- infra/03a-locals-infra.tf: Append entries
- project_ids: atlantis-ops = var.atlantis_project

## tfvars maps
- terraform.tfvars: Append keys using the “-ops” convention
- spokes: "atlantis-ops" = "terraform@atlantis-ops.iam.gserviceaccount.com"
- spoke_regions: "atlantis-ops" = "<region>"
- subnet_cidrs: "atlantis-ops" = "<cidr>"
- startup_scripts: "atlantis-ops" = "scripts/startup/<script>.sh"

Also set the scalar vars:
- atlantis_project, atlantis_region, atlantis_zone, atlantis_sa
- Infra modules (optional, if you want full infra for the new project)

## VPC: infra/03-vpc.tf
- Add module "atlantis_vpc" with providers = { google = google.atlantis-ops }

## Subnet: infra/04-subnets.tf
- Add module "atlantis_subnet" with providers = { google = google.atlantis-ops }
- cidr = var.subnet_cidrs["atlantis-ops"]

## Hub: infra/06-gcp-hub.tf
- Add module "atlantis_hub" with providers = { google = google.atlantis-ops }

## Spoke: infra/07-spokes.tf
- Add module "atlantis_spoke" with providers = { google = google.atlantis-ops }
- Attach the relevant VPN tunnels if applicable

## Compute: infra/08a-compute.tf
- Add module "atlantis_vm" with providers = { google = google.atlantis-ops }
- project = var.atlantis_project, zone = var.atlantis_zone, service_account_email = var.atlantis_sa
- project_key = "atlantis-ops" (so it reads startup_scripts["atlantis-ops"])

***Notes***
- Keys you append to maps are the logical aliases (e.g., "atlantis-ops"), not the raw project IDs unless they match.
- For naming convention with modules/compute project_key use “-ops”
- If you only need IAM bootstrap (not infra), you can skip the infra module additions; just do providers, locals, and tfvars.

