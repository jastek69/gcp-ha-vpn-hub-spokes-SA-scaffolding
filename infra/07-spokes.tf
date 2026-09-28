############################################################
# VPN Spokes
############################################################

module "balerica_spoke" {
  source = "../modules/spoke"

  providers = {
    google = google.taaops
  }

  project = var.balerica_project
  region  = var.balerica_region
  name    = "balerica"
  hub_id  = module.balerica_hub.hub_id
  vpn_tunnel_uris = [
    google_compute_vpn_tunnel.tunnels_taaops["balerica-genosha-t0"].self_link,
    google_compute_vpn_tunnel.tunnels_taaops["balerica-genosha-t1"].self_link,
  ]
}

module "genosha_spoke" {
  source = "../modules/spoke"

  providers = {
    google = google.genosha-ops
  }

  project = var.genosha_project
  region  = var.genosha_region
  name    = "genosha"
  hub_id  = module.genosha_hub.hub_id
  vpn_tunnel_uris = [
    google_compute_vpn_tunnel.tunnels_genosha["genosha-balerica-t0"].self_link,
    google_compute_vpn_tunnel.tunnels_genosha["genosha-balerica-t1"].self_link,
  ]
}


module "wakanda_spoke" {
  source = "../modules/spoke"

  providers = {
    google = google.wakanda-ops
  }

  project = var.wakanda_project
  region  = var.wakanda_region
  name    = "wakanda"
  hub_id  = module.wakanda_hub.hub_id
  vpn_tunnel_uris = [
    google_compute_vpn_tunnel.tunnels_wakanda["wakanda-balerica-t0"].self_link,
    google_compute_vpn_tunnel.tunnels_wakanda["wakanda-balerica-t1"].self_link,
  ]

}


module "tiqs_spoke" {
  source = "../modules/spoke"

  providers = {
    google = google.tiqs-ops
  }

  project = var.tiqs_project
  region  = var.tiqs_region
  name    = "tiqs"
  hub_id  = module.tiqs_hub.hub_id
  vpn_tunnel_uris = [
    google_compute_vpn_tunnel.tunnels_tiqs["tiqs-balerica-t0"].self_link,
    google_compute_vpn_tunnel.tunnels_tiqs["tiqs-balerica-t1"].self_link,
  ]
}


module "daleops_spoke" {
  source = "../modules/spoke"

  providers = {
    google = google.dale-ops
  }

  project = var.dale_project
  region  = var.dale_region
  name    = "daleops"
  hub_id  = module.daleops_hub.hub_id
  vpn_tunnel_uris = [
    google_compute_vpn_tunnel.tunnels_daleops["daleops-balerica-t0"].self_link,
    google_compute_vpn_tunnel.tunnels_daleops["daleops-balerica-t1"].self_link,
  ]
}


module "casops_spoke" {
  source = "../modules/spoke"

  providers = {
    google = google.cas-ops
  }

  project = var.cas_project
  region  = var.cas_region
  name    = "casops"
  hub_id  = module.casops_hub.hub_id
  vpn_tunnel_uris = [
    google_compute_vpn_tunnel.tunnels_casops["casops-balerica-t0"].self_link,
    google_compute_vpn_tunnel.tunnels_casops["casops-balerica-t1"].self_link,
  ]
}
