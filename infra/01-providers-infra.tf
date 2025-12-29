# Providers

terraform {
  backend "gcs" {
    bucket      = "taaopsfirstterraformbucket"
    prefix      = "terraform/infra-state-112325"
    credentials = "../taaops-e9943412868a.json"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.36.0"
    }
  }
}

############################################
# 01-providers-infra.tf
# Infrastructure provider configurations
# Explicit provider aliases per project
############################################

# Default provider → use Balerica as the hub project
provider "google" {
  project                     = var.balerica_project
  region                      = var.balerica_region
  impersonate_service_account = var.bootstrap_mode ? null : var.balerica_sa
}


# Explicit provider for Balerica
provider "google" {
  alias                       = "taaops"
  project                     = var.balerica_project
  region                      = var.balerica_region
  impersonate_service_account = var.bootstrap_mode ? null : local.spoke_sa_by_project_id[var.balerica_project]
}

# (removed underscore-style aliases; use hyphenated ones below)

provider "google" {
  alias                       = "genosha-ops"
  project                     = var.genosha_project
  region                      = var.genosha_region
  impersonate_service_account = var.bootstrap_mode ? null : local.spoke_sa_by_project_id[var.genosha_project]
}

provider "google" {
  alias                       = "wakanda-ops"
  project                     = var.wakanda_project
  region                      = var.wakanda_region
  impersonate_service_account = var.bootstrap_mode ? null : local.spoke_sa_by_project_id[var.wakanda_project]
}


provider "google" {
  alias                       = "class-6-5-tiqs"
  project                     = var.tiqs_project
  region                      = var.tiqs_region
  impersonate_service_account = var.bootstrap_mode ? null : local.spoke_sa_by_project_id[var.tiqs_project]
}

provider "google" {
  alias                       = "tiqs-ops"
  project                     = var.tiqs_project
  region                      = var.tiqs_region
  impersonate_service_account = var.bootstrap_mode ? null : local.spoke_sa_by_project_id[var.tiqs_project]
}




provider "google" {
  alias                       = "changing3-15-25"
  project                     = var.dale_project
  region                      = var.dale_region
  impersonate_service_account = var.bootstrap_mode ? null : local.spoke_sa_by_project_id[var.dale_project]
}


provider "google" {
  alias                       = "dale-ops"
  project                     = var.dale_project
  region                      = var.dale_region
  impersonate_service_account = var.bootstrap_mode ? null : local.spoke_sa_by_project_id[var.dale_project]
}

provider "google" {
  alias                       = "cas-ops"
  project                     = var.cas_project
  region                      = var.cas_region
  impersonate_service_account = var.bootstrap_mode ? null : local.spoke_sa_by_project_id[var.cas_project]
}




# Future expansion: add Atlantis, Dale, Tiqs here as needed
# Example:
# provider "google" {
#   alias                       = "atlantis-ops"
#   project                     = "atlantis-ops"
#   region                      = var.atlantis_region
#   impersonate_service_account = var.bootstrap_mode ? null : local.spoke_sa_by_project_id["atlantis-ops"]
# }
