# Architecture

Diagrams for the hub-and-spoke HA VPN scaffold. Narrative: [`../README.md`](../README.md). Detailed network logic: [`SETUP-GUIDE.md`](SETUP-GUIDE.md) (sections "Hub and Spokes Network Configuration" and "Full dependency chain").

## Two phases, two roots

```mermaid
flowchart LR
    subgraph B["bootstrap/ — bootstrap_mode = true"]
        ADC["Owner ADC<br/>gcloud auth application-default login"] --> SA["Terraform SA per project"]
        SA --> R1["baseline roles"]
        SA --> R2["custom role terraform_vpn_role"]
        SA --> X["cross-project bindings<br/>+ Token Creator for impersonation"]
    end
    subgraph I["infra/ — bootstrap_mode = false"]
        IMP["provider impersonate_service_account"] --> NET[VPCs · subnets]
        NET --> GW[HA VPN gateways] --> TUN[tunnels] --> RI[router interfaces] --> PEER[BGP peers]
        TUN --> SPK[NCC spokes] --> HUB[NCC hubs]
        NET --> VM[test VMs]
    end
    B -->|once| I
    CI["CI: Workload Identity Federation"] -.-> IMP
```

## One tunnel pair

```mermaid
flowchart LR
    subgraph A["Project A — ASN 65501"]
        GA["HA VPN gateway<br/>interfaces 0, 1"] --- CRA[Cloud Router]
    end
    subgraph Bp["Project B — ASN 65515"]
        GB["HA VPN gateway<br/>interfaces 0, 1"] --- CRB[Cloud Router]
    end
    GA <==>|"tunnel 0 · PSK · 169.254.x.y/30"| GB
    GA <==>|"tunnel 1 · PSK · 169.254.x.z/30"| GB
    CRA <-.->|BGP session per tunnel| CRB
```

Router interface `ip_range` = the full `/30`. Peer `peer_ip_address` = `split("/", cidr)[0]`.

## Data-driven expansion

```mermaid
flowchart TD
    V["var.tunnels (tfvars)<br/>{ pair → { src, dst, asn, psk, tunnels{t0,t1} } }"] --> F1["vpn_tunnels_flattened<br/>one record per tunnel"]
    V --> F2["router_flattened<br/>+ ASNs, interface IPs"]
    V --> F3["tunnel_projects<br/>deduplicated project set"]
    F1 --> T["google_compute_vpn_tunnel<br/>for_each: &lt;pair&gt;-&lt;t#&gt;"]
    F2 --> RIF["google_compute_router_interface / _peer"]
    F3 --> G["google_compute_ha_vpn_gateway<br/>one per project"]
    F3 --> RT["google_compute_router<br/>one per project"]
    F1 --> S["NCC spoke.linked_vpn_tunnels<br/>= tunnels where src == project"]
```

Adding a project = one `spokes` entry + its `tunnels` entries. Nothing else changes.
