# ============================================
# 14-router.tf
# Routers, Interfaces, and Peers
# ============================================

# Cloud Routers per project
# --------------------------------------------------------------
# Routers
# --------------------------------------------------------------
resource "google_compute_router" "routers_taaops" {
  provider = google.taaops
  for_each = contains(local.tunnel_projects, "taaops") ? toset(["taaops"]) : toset([])

  name    = "${each.value}-router"
  project = local.project_ids[each.value]
  region  = var.spoke_regions[each.value]
  network = local.vpc_ids[each.value]

  bgp {
    asn = (
      local.project_ids[each.value] == var.balerica_project ? 65501 :
      local.project_ids[each.value] == var.genosha_project ? 65515 :
      local.project_ids[each.value] == var.wakanda_project ? 65520 :
      local.project_ids[each.value] == var.tiqs_project ? 65530 :
      local.project_ids[each.value] == var.dale_project ? 65534 :
      65000 # fallback ASN for future spokes
    )
  }
}

resource "google_compute_router" "routers_genosha" {
  provider = google.genosha-ops
  for_each = contains(local.tunnel_projects, "genosha-ops") ? toset(["genosha-ops"]) : toset([])

  name    = "${each.value}-router"
  project = local.project_ids[each.value]
  region  = var.spoke_regions[each.value]
  network = local.vpc_ids[each.value]

  bgp {
    asn = (
      local.project_ids[each.value] == var.balerica_project ? 65501 :
      local.project_ids[each.value] == var.genosha_project ? 65515 :
      local.project_ids[each.value] == var.wakanda_project ? 65520 :
      local.project_ids[each.value] == var.tiqs_project ? 65530 :
      local.project_ids[each.value] == var.dale_project ? 65534 :
      65000
    )
  }
}

resource "google_compute_router" "routers_wakanda" {
  provider = google.wakanda-ops
  for_each = contains(local.tunnel_projects, "wakanda-ops") ? toset(["wakanda-ops"]) : toset([])

  name    = "${each.value}-router"
  project = local.project_ids[each.value]
  region  = var.spoke_regions[each.value]
  network = local.vpc_ids[each.value]

  bgp {
    asn = (
      local.project_ids[each.value] == var.balerica_project ? 65501 :
      local.project_ids[each.value] == var.genosha_project ? 65515 :
      local.project_ids[each.value] == var.wakanda_project ? 65520 :
      local.project_ids[each.value] == var.tiqs_project ? 65530 :
      local.project_ids[each.value] == var.dale_project ? 65534 :
      65000
    )
  }
}

resource "google_compute_router" "routers_tiqs" {
  provider = google.tiqs-ops
  for_each = contains(local.tunnel_projects, "tiqs-ops") ? toset(["tiqs-ops"]) : toset([])

  name    = "${each.value}-router"
  project = local.project_ids[each.value]
  region  = var.spoke_regions[each.value]
  network = local.vpc_ids[each.value]

  bgp {
    asn = (
      local.project_ids[each.value] == var.balerica_project ? 65501 :
      local.project_ids[each.value] == var.genosha_project ? 65515 :
      local.project_ids[each.value] == var.wakanda_project ? 65520 :
      local.project_ids[each.value] == var.tiqs_project ? 65530 :
      local.project_ids[each.value] == var.dale_project ? 65534 :
      65000
    )
  }
}



resource "google_compute_router" "routers_daleops" {
  provider = google.dale-ops
  for_each = contains(local.tunnel_projects, "dale-ops") ? toset(["dale-ops"]) : toset([])

  name    = "${each.value}-router"
  project = local.project_ids[each.value]
  region  = var.spoke_regions[each.value]
  network = local.vpc_ids[each.value]

  bgp {
    asn = (
      local.project_ids[each.value] == var.balerica_project ? 65501 :
      local.project_ids[each.value] == var.genosha_project ? 65515 :
      local.project_ids[each.value] == var.wakanda_project ? 65520 :
      local.project_ids[each.value] == var.tiqs_project ? 65530 :
      local.project_ids[each.value] == var.dale_project ? 65534 :
      65000
    )
  }
}

resource "google_compute_router" "routers_casops" {
  provider = google.cas-ops
  for_each = contains(local.tunnel_projects, "cas-ops") ? toset(["cas-ops"]) : toset([])

  name    = "${each.value}-router"
  project = local.project_ids[each.value]
  region  = var.spoke_regions[each.value]
  network = local.vpc_ids[each.value]

  bgp {
    asn = (
      local.project_ids[each.value] == var.balerica_project ? 65501 :
      local.project_ids[each.value] == var.genosha_project ? 65515 :
      local.project_ids[each.value] == var.wakanda_project ? 65520 :
      local.project_ids[each.value] == var.tiqs_project ? 65530 :
      local.project_ids[each.value] == var.dale_project ? 65534 :
      local.project_ids[each.value] == var.cas_project ? 65533 :
      65000
    )
  }
}


# --------------------------------------------------------------
# Router interfaces (bind tunnels to routers with /30 ranges)
# --------------------------------------------------------------
resource "google_compute_router_interface" "interfaces_taaops" {
  provider = google.taaops
  for_each = {
    for key, value in local.router_map :
    key => value if value.src_key == "taaops" && contains(keys(google_compute_vpn_tunnel.tunnels_taaops), key)
  }
  name       = each.value.tunnel
  project    = each.value.src_project_id
  region     = each.value.region
  router     = google_compute_router.routers_taaops[each.value.src_key].name
  ip_range   = each.value.ip_range
  vpn_tunnel = google_compute_vpn_tunnel.tunnels_taaops[each.key].name
}

resource "google_compute_router_interface" "interfaces_genosha" {
  provider = google.genosha-ops
  for_each = {
    for key, value in local.router_map :
    key => value if value.src_key == "genosha-ops" && contains(keys(google_compute_vpn_tunnel.tunnels_genosha), key)
  }
  name       = each.value.tunnel
  project    = each.value.src_project_id
  region     = each.value.region
  router     = google_compute_router.routers_genosha[each.value.src_key].name
  ip_range   = each.value.ip_range
  vpn_tunnel = google_compute_vpn_tunnel.tunnels_genosha[each.key].name
}

resource "google_compute_router_interface" "interfaces_wakanda" {
  provider = google.wakanda-ops
  for_each = {
    for key, value in local.router_map :
    key => value if value.src_key == "wakanda-ops" && contains(keys(google_compute_vpn_tunnel.tunnels_wakanda), key)
  }
  name       = each.value.tunnel
  project    = each.value.src_project_id
  region     = each.value.region
  router     = google_compute_router.routers_wakanda[each.value.src_key].name
  ip_range   = each.value.ip_range
  vpn_tunnel = google_compute_vpn_tunnel.tunnels_wakanda[each.key].name
}

resource "google_compute_router_interface" "interfaces_tiqs" {
  provider = google.tiqs-ops
  for_each = {
    for key, value in local.router_map :
    key => value if value.src_key == "tiqs-ops" && contains(keys(google_compute_vpn_tunnel.tunnels_tiqs), key)
  }
  name       = each.value.tunnel
  project    = each.value.src_project_id
  region     = each.value.region
  router     = google_compute_router.routers_tiqs[each.value.src_key].name
  ip_range   = each.value.ip_range
  vpn_tunnel = google_compute_vpn_tunnel.tunnels_tiqs[each.key].name
}


resource "google_compute_router_interface" "interfaces_daleops" {
  provider = google.dale-ops
  for_each = {
    for key, value in local.router_map :
    key => value if value.src_key == "dale-ops" && contains(keys(google_compute_vpn_tunnel.tunnels_daleops), key)
  }
  name       = each.value.tunnel
  project    = each.value.src_project_id
  region     = each.value.region
  router     = google_compute_router.routers_daleops[each.value.src_key].name
  ip_range   = each.value.ip_range
  vpn_tunnel = google_compute_vpn_tunnel.tunnels_daleops[each.key].name
}

resource "google_compute_router_interface" "interfaces_casops" {
  provider = google.cas-ops
  for_each = {
    for key, value in local.router_map :
    key => value if value.src_key == "cas-ops" && contains(keys(google_compute_vpn_tunnel.tunnels_casops), key)
  }
  name       = each.value.tunnel
  project    = each.value.src_project_id
  region     = each.value.region
  router     = google_compute_router.routers_casops[each.value.src_key].name
  ip_range   = each.value.ip_range
  vpn_tunnel = google_compute_vpn_tunnel.tunnels_casops[each.key].name
}





# --------------------------------------------------------------
# Router peers (BGP sessions across tunnels)
# --------------------------------------------------------------
resource "google_compute_router_peer" "peers_taaops" {
  provider = google.taaops
  for_each = {
    for key, value in local.router_map :
    key => value if value.src_key == "taaops" && contains(keys(google_compute_vpn_tunnel.tunnels_taaops), key)
  }
  name            = "${each.value.src_key}-to-${each.value.dst_key}-${each.value.name}-peer"
  project         = each.value.src_project_id
  region          = each.value.region
  router          = google_compute_router.routers_taaops[each.value.src_key].name
  interface       = google_compute_router_interface.interfaces_taaops[each.key].name
  ip_address      = split("/", local.vpn_tunnels_map[each.key].ip_src)[0]
  peer_ip_address = split("/", local.vpn_tunnels_map[each.key].ip_dst)[0]
  peer_asn        = each.value.peer_asn
}

resource "google_compute_router_peer" "peers_genosha" {
  provider = google.genosha-ops
  for_each = {
    for key, value in local.router_map :
    key => value if value.src_key == "genosha-ops" && contains(keys(google_compute_vpn_tunnel.tunnels_genosha), key)
  }
  name            = "${each.value.src_key}-to-${each.value.dst_key}-${each.value.name}-peer"
  project         = each.value.src_project_id
  region          = each.value.region
  router          = google_compute_router.routers_genosha[each.value.src_key].name
  interface       = google_compute_router_interface.interfaces_genosha[each.key].name
  ip_address      = split("/", local.vpn_tunnels_map[each.key].ip_src)[0]
  peer_ip_address = split("/", local.vpn_tunnels_map[each.key].ip_dst)[0]
  peer_asn        = each.value.peer_asn
}

resource "google_compute_router_peer" "peers_wakanda" {
  provider = google.wakanda-ops
  for_each = {
    for key, value in local.router_map :
    key => value if value.src_key == "wakanda-ops" && contains(keys(google_compute_vpn_tunnel.tunnels_wakanda), key)
  }
  name            = "${each.value.src_key}-to-${each.value.dst_key}-${each.value.name}-peer"
  project         = each.value.src_project_id
  region          = each.value.region
  router          = google_compute_router.routers_wakanda[each.value.src_key].name
  interface       = google_compute_router_interface.interfaces_wakanda[each.key].name
  ip_address      = split("/", local.vpn_tunnels_map[each.key].ip_src)[0]
  peer_ip_address = split("/", local.vpn_tunnels_map[each.key].ip_dst)[0]
  peer_asn        = each.value.peer_asn
}

resource "google_compute_router_peer" "peers_tiqs" {
  provider = google.tiqs-ops
  for_each = {
    for key, value in local.router_map :
    key => value if value.src_key == "tiqs-ops" && contains(keys(google_compute_vpn_tunnel.tunnels_tiqs), key)
  }
  name            = "${each.value.src_key}-to-${each.value.dst_key}-${each.value.name}-peer"
  project         = each.value.src_project_id
  region          = each.value.region
  router          = google_compute_router.routers_tiqs[each.value.src_key].name
  interface       = google_compute_router_interface.interfaces_tiqs[each.key].name
  ip_address      = split("/", local.vpn_tunnels_map[each.key].ip_src)[0]
  peer_ip_address = split("/", local.vpn_tunnels_map[each.key].ip_dst)[0]
  peer_asn        = each.value.peer_asn
}


resource "google_compute_router_peer" "peers_daleops" {
  provider = google.dale-ops
  for_each = {
    for key, value in local.router_map :
    key => value if value.src_key == "dale-ops" && contains(keys(google_compute_vpn_tunnel.tunnels_daleops), key)
  }
  name            = "${each.value.src_key}-to-${each.value.dst_key}-${each.value.name}-peer"
  project         = each.value.src_project_id
  region          = each.value.region
  router          = google_compute_router.routers_daleops[each.value.src_key].name
  interface       = google_compute_router_interface.interfaces_daleops[each.key].name
  ip_address      = split("/", local.vpn_tunnels_map[each.key].ip_src)[0]
  peer_ip_address = split("/", local.vpn_tunnels_map[each.key].ip_dst)[0]
  peer_asn        = each.value.peer_asn
}


resource "google_compute_router_peer" "peers_casops" {
  provider = google.cas-ops
  for_each = {
    for key, value in local.router_map :
    key => value if value.src_key == "cas-ops" && contains(keys(google_compute_vpn_tunnel.tunnels_casops), key)
  }
  name            = "${each.value.src_key}-to-${each.value.dst_key}-${each.value.name}-peer"
  project         = each.value.src_project_id
  region          = each.value.region
  router          = google_compute_router.routers_casops[each.value.src_key].name
  interface       = google_compute_router_interface.interfaces_casops[each.key].name
  ip_address      = split("/", local.vpn_tunnels_map[each.key].ip_src)[0]
  peer_ip_address = split("/", local.vpn_tunnels_map[each.key].ip_dst)[0]
  peer_asn        = each.value.peer_asn
}
