# Output for Infrastructure
# ================================
# IAM Sanity Checks
# ================================

output "spoke_sas" {
  description = "Project → Terraform SA email"
  value       = local.spoke_sas
}

// Bootstrap-only IAM outputs removed from infra to keep validation clean

# ================================
# VPN + Router Sanity Checks
# ================================

locals {
  vpn_tunnels_all = merge(
    google_compute_vpn_tunnel.tunnels_taaops,
    google_compute_vpn_tunnel.tunnels_genosha,
    google_compute_vpn_tunnel.tunnels_wakanda,
    google_compute_vpn_tunnel.tunnels_tiqs,
    google_compute_vpn_tunnel.tunnels_daleops,
    google_compute_vpn_tunnel.tunnels_casops,
  )
}

output "vpn_tunnels" {
  description = "All VPN tunnels created (flattened)"
  value = {
    for k, v in local.vpn_tunnels_all : k => {
      name   = v.name
      src    = v.project
      region = v.region
      peer   = v.peer_ip
    }
  }
}

locals {
  router_interfaces_all = merge(
    google_compute_router_interface.interfaces_taaops,
    google_compute_router_interface.interfaces_genosha,
    google_compute_router_interface.interfaces_wakanda,
    google_compute_router_interface.interfaces_tiqs,
    google_compute_router_interface.interfaces_daleops,
    google_compute_router_interface.interfaces_casops,
  )
}

output "router_interfaces" {
  description = "Router interfaces created (flattened)"
  value = {
    for k, v in local.router_interfaces_all : k => {
      name   = v.name
      router = v.router
      region = v.region
      ip     = v.ip_range
    }
  }
}

locals {
  router_peers_all = merge(
    google_compute_router_peer.peers_taaops,
    google_compute_router_peer.peers_genosha,
    google_compute_router_peer.peers_wakanda,
    google_compute_router_peer.peers_tiqs,
    google_compute_router_peer.peers_daleops,
    google_compute_router_peer.peers_casops,
  )
}

output "router_peers" {
  description = "Router peers created (flattened)"
  value = {
    for k, v in local.router_peers_all : k => {
      name   = v.name
      router = v.router
      peer   = v.peer_ip_address
      asn    = v.peer_asn
    }
  }
}
