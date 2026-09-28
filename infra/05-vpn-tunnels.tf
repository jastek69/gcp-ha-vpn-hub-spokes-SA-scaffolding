############################################################
# 05-vpn-tunnels.tf
# HA VPN Gateways + Tunnels
############################################################

# HA VPN Gateways (one per source project), pinned to per-project providers
resource "google_compute_ha_vpn_gateway" "gateways_taaops" {
  provider = google.taaops
  for_each = contains(local.tunnel_projects, "taaops") ? toset(["taaops"]) : toset([])
  name     = "${each.value}-gateway"
  project  = local.project_ids[each.value]
  region   = var.spoke_regions[each.value]
  network  = local.vpc_ids[each.value]
}

resource "google_compute_ha_vpn_gateway" "gateways_genosha" {
  provider = google.genosha-ops
  for_each = contains(local.tunnel_projects, "genosha-ops") ? toset(["genosha-ops"]) : toset([])
  name     = "${each.value}-gateway"
  project  = local.project_ids[each.value]
  region   = var.spoke_regions[each.value]
  network  = local.vpc_ids[each.value]
}

resource "google_compute_ha_vpn_gateway" "gateways_wakanda" {
  provider = google.wakanda-ops
  for_each = contains(local.tunnel_projects, "wakanda-ops") ? toset(["wakanda-ops"]) : toset([])
  name     = "${each.value}-gateway"
  project  = local.project_ids[each.value]
  region   = var.spoke_regions[each.value]
  network  = local.vpc_ids[each.value]
}

resource "google_compute_ha_vpn_gateway" "gateways_tiqs" {
  provider = google.tiqs-ops
  for_each = contains(local.tunnel_projects, "tiqs-ops") ? toset(["tiqs-ops"]) : toset([])
  name     = "${each.value}-gateway"
  project  = local.project_ids[each.value]
  region   = var.spoke_regions[each.value]
  network  = local.vpc_ids[each.value]
}


resource "google_compute_ha_vpn_gateway" "gateways_daleops" {
  provider = google.dale-ops
  for_each = contains(local.tunnel_projects, "dale-ops") ? toset(["dale-ops"]) : toset([])
  name     = "${each.value}-gateway"
  project  = local.project_ids[each.value]
  region   = var.spoke_regions[each.value]
  network  = local.vpc_ids[each.value]
}


resource "google_compute_ha_vpn_gateway" "gateways_casops" {
  provider = google.cas-ops
  for_each = contains(local.tunnel_projects, "cas-ops") ? toset(["cas-ops"]) : toset([])
  name     = "${each.value}-gateway"
  project  = local.project_ids[each.value]
  region   = var.spoke_regions[each.value]
  network  = local.vpc_ids[each.value]
}


# Interface index mapping based on tunnel name suffix (t0 -> 0, t1 -> 1, etc.)
locals {
  # Lookup map of project_id -> HA VPN gateway self_link, merged across projects
  gateway_self_links = merge(
    { for k, v in google_compute_ha_vpn_gateway.gateways_taaops : k => v.self_link },
    { for k, v in google_compute_ha_vpn_gateway.gateways_genosha : k => v.self_link },
    { for k, v in google_compute_ha_vpn_gateway.gateways_wakanda : k => v.self_link },
    { for k, v in google_compute_ha_vpn_gateway.gateways_tiqs : k => v.self_link },
    { for k, v in google_compute_ha_vpn_gateway.gateways_daleops : k => v.self_link },
    { for k, v in google_compute_ha_vpn_gateway.gateways_casops : k => v.self_link }
    # future spokes extend here
  )
}


# --------------------------------------------------------------
# HA VPN Tunnels
# --------------------------------------------------------------
# Create only the tunnels that work (t0 and t1 from each direction)
resource "google_compute_vpn_tunnel" "tunnels_taaops" {
  provider = google.taaops
  for_each = {
    # Only include working tunnel pairs

    # Genosha-Balerica pairs
    "balerica-genosha-t0" = local.vpn_tunnels_map["balerica-genosha-t0"]
    "balerica-genosha-t1" = local.vpn_tunnels_map["balerica-genosha-t1"]

    # Reverse direction handled in provider-specific blocks below

    # Wakanda pairs
    "balerica-wakanda-t0" = local.vpn_tunnels_map["balerica-wakanda-t0"]
    "balerica-wakanda-t1" = local.vpn_tunnels_map["balerica-wakanda-t1"]
    # Reverse direction handled in provider-specific blocks below


    # TIQS-Balerica pairs
    "balerica-tiqs-t0" = local.vpn_tunnels_map["balerica-tiqs-t0"]
    "balerica-tiqs-t1" = local.vpn_tunnels_map["balerica-tiqs-t1"]
    # Reverse direction handled in provider-specific blocks below


    # daleops-balerica pairs
    "balerica-daleops-t0" = local.vpn_tunnels_map["balerica-daleops-t0"]
    "balerica-daleops-t1" = local.vpn_tunnels_map["balerica-daleops-t1"]
    # Reverse direction handled in provider-specific blocks below


    # casops-balerica pairs
    "balerica-casops-t0" = local.vpn_tunnels_map["balerica-casops-t0"]
    "balerica-casops-t1" = local.vpn_tunnels_map["balerica-casops-t1"]
    # Reverse direction handled in provider-specific blocks below


    /*
    "genosha-wakanda-t0"  = local.vpn_tunnels_map["genosha-wakanda-t0"]
    "genosha-wakanda-t1"  = local.vpn_tunnels_map["genosha-wakanda-t1"]
    
    "wakanda-genosha-t0"  = local.vpn_tunnels_map["wakanda-genosha-t0"]
    "wakanda-genosha-t1"  = local.vpn_tunnels_map["wakanda-genosha-t1"]


    # Future expansions - add new ones as needed:
    # "balerica-future-t0" = local.vpn_tunnels_map["balerica-future-t0"]  # Will work!
    # "future-balerica-t0" = local.vpn_tunnels_map["future-balerica-t0"]  # Will work!
  */
  }

  name        = "${each.value.src}-to-${each.value.dst}-${each.value.name}"
  project     = local.project_ids[each.value.src]
  region      = each.value.region_src
  vpn_gateway = local.gateway_self_links[each.value.src]

  # Select HA VPN interface index based on tunnel name (t0/t1/t2/t3 → 0/1)
  vpn_gateway_interface = local.interface_index[each.value.name]

  # Shared secret (PSK) from your tunnels map
  shared_secret = each.value.psk

  # Peer GCP Gateway - This is the key missing piece
  peer_gcp_gateway = local.gateway_self_links[each.value.dst]

  # Use correct router reference
  router = google_compute_router.routers_taaops[each.value.src].self_link

  ike_version = 2
}

# Reverse/other source projects
resource "google_compute_vpn_tunnel" "tunnels_genosha" {
  provider = google.genosha-ops
  for_each = {
    "genosha-balerica-t0" = local.vpn_tunnels_map["genosha-balerica-t0"]
    "genosha-balerica-t1" = local.vpn_tunnels_map["genosha-balerica-t1"]
  }

  name                  = "${each.value.src}-to-${each.value.dst}-${each.value.name}"
  project               = local.project_ids[each.value.src]
  region                = each.value.region_src
  vpn_gateway           = local.gateway_self_links[each.value.src]
  vpn_gateway_interface = local.interface_index[each.value.name]
  shared_secret         = each.value.psk
  peer_gcp_gateway      = local.gateway_self_links[each.value.dst]
  router                = google_compute_router.routers_genosha[each.value.src].self_link
  ike_version           = 2
}

resource "google_compute_vpn_tunnel" "tunnels_wakanda" {
  provider = google.wakanda-ops
  for_each = {
    "wakanda-balerica-t0" = local.vpn_tunnels_map["wakanda-balerica-t0"]
    "wakanda-balerica-t1" = local.vpn_tunnels_map["wakanda-balerica-t1"]
  }

  name                  = "${each.value.src}-to-${each.value.dst}-${each.value.name}"
  project               = local.project_ids[each.value.src]
  region                = each.value.region_src
  vpn_gateway           = local.gateway_self_links[each.value.src]
  vpn_gateway_interface = local.interface_index[each.value.name]
  shared_secret         = each.value.psk
  peer_gcp_gateway      = local.gateway_self_links[each.value.dst]
  router                = google_compute_router.routers_wakanda[each.value.src].self_link
  ike_version           = 2
}

resource "google_compute_vpn_tunnel" "tunnels_tiqs" {
  provider = google.tiqs-ops
  for_each = {
    "tiqs-balerica-t0" = local.vpn_tunnels_map["tiqs-balerica-t0"]
    "tiqs-balerica-t1" = local.vpn_tunnels_map["tiqs-balerica-t1"]
  }

  name                  = "${each.value.src}-to-${each.value.dst}-${each.value.name}"
  project               = local.project_ids[each.value.src]
  region                = each.value.region_src
  vpn_gateway           = local.gateway_self_links[each.value.src]
  vpn_gateway_interface = local.interface_index[each.value.name]
  shared_secret         = each.value.psk
  peer_gcp_gateway      = local.gateway_self_links[each.value.dst]
  router                = google_compute_router.routers_tiqs[each.value.src].self_link
  ike_version           = 2
}


resource "google_compute_vpn_tunnel" "tunnels_daleops" {
  provider = google.dale-ops
  for_each = {
    "daleops-balerica-t0" = local.vpn_tunnels_map["daleops-balerica-t0"]
    "daleops-balerica-t1" = local.vpn_tunnels_map["daleops-balerica-t1"]
  }

  name                  = "${each.value.src}-to-${each.value.dst}-${each.value.name}"
  project               = local.project_ids[each.value.src]
  region                = each.value.region_src
  vpn_gateway           = local.gateway_self_links[each.value.src]
  vpn_gateway_interface = local.interface_index[each.value.name]
  shared_secret         = each.value.psk
  peer_gcp_gateway      = local.gateway_self_links[each.value.dst]
  router                = google_compute_router.routers_daleops[each.value.src].self_link
  ike_version           = 2
}



resource "google_compute_vpn_tunnel" "tunnels_casops" {
  provider = google.cas-ops
  for_each = {
    "casops-balerica-t0" = local.vpn_tunnels_map["casops-balerica-t0"]
    "casops-balerica-t1" = local.vpn_tunnels_map["casops-balerica-t1"]
  }

  name                  = "${each.value.src}-to-${each.value.dst}-${each.value.name}"
  project               = local.project_ids[each.value.src]
  region                = each.value.region_src
  vpn_gateway           = local.gateway_self_links[each.value.src]
  vpn_gateway_interface = local.interface_index[each.value.name]
  shared_secret         = each.value.psk
  peer_gcp_gateway      = local.gateway_self_links[each.value.dst]
  router                = google_compute_router.routers_casops[each.value.src].self_link
  ike_version           = 2
}
