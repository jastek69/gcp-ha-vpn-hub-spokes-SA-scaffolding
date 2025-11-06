############################################################
# 04-subnets.tf
# Explicit per-project Subnets (Option A)
############################################################

# ----------------------
# Balerica Subnet
# ----------------------
module "balerica_subnet" {
  source = "../modules/subnet"

  providers = {
    google = google.taaops
  }

  project = var.balerica_project
  region  = var.balerica_region
  cidr    = var.subnet_cidrs["taaops"]
  network = module.balerica_vpc.vpc_self_link
  name    = "${var.balerica_project}-subnet"
}

# ----------------------
# Genosha Subnet
# ----------------------
module "genosha_subnet" {
  source = "../modules/subnet"

  providers = {
    google = google.genosha-ops
  }

  project = var.genosha_project
  region  = var.genosha_region
  cidr    = var.subnet_cidrs["genosha-ops"]
  network = module.genosha_vpc.vpc_self_link
  name    = "${var.genosha_project}-subnet"
}


module "wakanda_subnet" {
  source = "../modules/subnet"

  providers = {
    google = google.wakanda-ops
  }

  project = var.wakanda_project
  region  = var.wakanda_region
  cidr    = var.subnet_cidrs["wakanda-ops"]
  network = module.wakanda_vpc.vpc_self_link
  name    = "${var.wakanda_project}-subnet"

}


module "tiqs_subnet" {
  source = "../modules/subnet"

  providers = {
    google = google.tiqs-ops
  }

  project = var.tiqs_project
  region  = var.tiqs_region
  cidr    = var.subnet_cidrs["tiqs-ops"]
  network = module.tiqs_vpc.vpc_self_link
  name    = "${var.tiqs_project}-subnet"

}
