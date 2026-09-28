############################################################
# 03-vpc.tf
# Explicit per-project VPCs (Option A)
############################################################

# ----------------------
# Balerica VPC
# ----------------------
module "balerica_vpc" {
  source = "../modules/vpc"

  providers = {
    google = google.taaops
  }

  project = var.balerica_project
  name    = "${var.balerica_project}-vpc"
}

# ----------------------
# Genosha VPC
# ----------------------
module "genosha_vpc" {
  source = "../modules/vpc"

  providers = {
    google = google.genosha-ops
  }

  project = var.genosha_project
  name    = "${var.genosha_project}-vpc"
}


# ----------------------
# Wakanda VPC
# ----------------------
module "wakanda_vpc" {
  source = "../modules/vpc"

  providers = {
    google = google.wakanda-ops
  }

  project = var.wakanda_project
  name    = "${var.wakanda_project}-vpc"
}


# ----------------------
# TIQS VPC
# ----------------------
module "tiqs_vpc" {
  source = "../modules/vpc"

  providers = {
    google = google.tiqs-ops
  }

  project = var.tiqs_project
  name    = "${var.tiqs_project}-vpc"
}


#----------------------
# Dale VPC
#----------------------
module "dale_vpc" {
  source = "../modules/vpc"

  providers = {
    google = google.dale-ops
  }

  project = var.dale_project
  name    = "${var.dale_project}-vpc"
}

module "cas_vpc" {
  source = "../modules/vpc"

  providers = {
    google = google.cas-ops
  }

  project = var.cas_project
  name    = "${var.cas_project}-vpc"
}


# future spokes extend here