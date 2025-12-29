############################################################
# 08a-compute.tf
# Explicit per-project VM deployments
############################################################

# ----------------------------------------------------------
# Balerica VM
# ----------------------------------------------------------
module "balerica_vm" {
  source = "../modules/compute"

  providers = {
    google = google.taaops
  }

  project               = var.balerica_project
  zone                  = var.balerica_zone
  instance_name         = "balerica-vm"
  machine_type          = "n2-standard-2"
  subnetwork            = module.balerica_subnet.subnet_id
  startup_scripts       = var.startup_scripts
  service_account_email = var.balerica_sa
  project_key           = "taaops"
}

# ----------------------------------------------------------
# Genosha VM
# ----------------------------------------------------------
module "genosha_vm" {
  source = "../modules/compute"

  providers = {
    google = google.genosha-ops
  }

  project               = var.genosha_project
  zone                  = var.genosha_zone
  instance_name         = "genosha-vm"
  machine_type          = "n2-standard-2"
  subnetwork            = module.genosha_subnet.subnet_id
  startup_scripts       = var.startup_scripts
  service_account_email = var.genosha_sa
  project_key           = "genosha-ops"
}


module "wakanda_vm" {
  source = "../modules/compute"

  providers = {
    google = google.wakanda-ops
  }

  project               = var.wakanda_project
  zone                  = var.wakanda_zone
  instance_name         = "wakanda-vm"
  machine_type          = "n2-standard-2"
  subnetwork            = module.wakanda_subnet.subnet_id
  startup_scripts       = var.startup_scripts
  service_account_email = var.wakanda_sa
  project_key           = "wakanda-ops"

}

module "tiqs_vm" {
  source = "../modules/compute"

  providers = {
    google = google.tiqs-ops
  }

  project               = var.tiqs_project
  zone                  = var.tiqs_zone
  instance_name         = "tiqs-vm"
  machine_type          = "n2-standard-2"
  subnetwork            = module.tiqs_subnet.subnet_id
  startup_scripts       = var.startup_scripts
  service_account_email = var.tiqs_sa
  project_key           = "class-6-5-tiqs"
}


module "daleops_vm" {
  source = "../modules/compute"

  providers = {
    google = google.dale-ops
  }

  project = var.dale_project
  zone = var.dale_zone
  instance_name = "daleops-vm"
  machine_type = "n2-standard-2"
  subnetwork = module.daleops_subnet.subnet_id
  startup_scripts = var.startup_scripts
  service_account_email = var.dale_sa
  project_key = "changing3-15-25"
}


module "casops_vm" {
  source = "../modules/compute"

  providers = {
    google = google.cas-ops
  }

  project               = var.cas_project
  zone                  = var.cas_zone
  instance_name         = "casops-vm"
  machine_type          = "e2-standard-2"
  subnetwork            = module.casops_subnet.subnet_id
  startup_scripts       = var.startup_scripts
  service_account_email = var.cas_sa
  project_key           = "cas-ops"
}
