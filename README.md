<div align="center">

# Kashall's Infrastructure

[![Discord](https://img.shields.io/discord/673534664354430999?style=flat-square&label&logo=discord&logoColor=white&color=blue)](https://discord.gg/home-operations)&nbsp;&nbsp;&nbsp;
[![Talos](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fbadges%2Ftalos_version%3Fformat%3Dshields&style=flat-square&logo=talos&logoColor=white&color=blue&label=%20)](https://www.talos.dev/)&nbsp;&nbsp;&nbsp;
[![Kubernetes](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fbadges%2Fkubernetes_version%3Fformat%3Dshields&style=flat-square&logo=kubernetes&logoColor=white&color=blue&label=%20)](https://www.talos.dev/)&nbsp;&nbsp;&nbsp;
[![Renovate](https://img.shields.io/github/actions/workflow/status/waifulabs/infrastructure/renovate.yaml?branch=main&label=&logo=renovatebot&style=flat-square&color=blue)](https://github.com/waifulabs/infrastructure/actions/workflows/renovate.yaml)

[![Age](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fbadges%2Fcluster_birth_age%3Fformat%3Dshields&style=flat-square&label=Age)](https://github.com/home-operations/kromgo/)&nbsp;&nbsp;&nbsp;
[![Uptime](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fbadges%2Fcluster_uptime_age%3Fformat%3Dshields&style=flat-square&label=Uptime)](https://github.com/home-operations/kromgo/)&nbsp;&nbsp;&nbsp;
[![Active-Alerts](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fbadges%2Fprometheus_active_alerts%3Fformat%3Dshields&style=flat-square&label=Firing%20Alerts)](https://github.com/home-operations/kromgo/)&nbsp;&nbsp;&nbsp;
[![Node-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fbadges%2Fcluster_node_count%3Fformat%3Dshields&style=flat-square&label=Nodes)](https://github.com/home-operations/kromgo/)&nbsp;&nbsp;&nbsp;
[![Pod-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fbadges%2Fcluster_pods_running%3Fformat%3Dshields&style=flat-square&label=Pods&color=green)](https://github.com/home-operations/kromgo/)&nbsp;&nbsp;&nbsp;
[![CPU-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fbadges%2Fcluster_cpu_usage%3Fformat%3Dshields&style=flat-square&label=CPU)](https://github.com/home-operations/kromgo/)&nbsp;&nbsp;&nbsp;
[![Power-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fbadges%2Fcluster_power_usage%3Fformat%3Dshields&style=flat-square&label=Power)](https://github.com/home-operations/kromgo/)

</div>

## Overview

This repository runs my **home lab** — a few computers in my house that host the apps and services my household depends on (media library, home automation, dashboards, chat, and more) instead of renting them from big cloud providers.

The twist: nothing is configured by hand. The *entire* setup is written down as code in this repo, and software continuously keeps the real machines matched to it. Push a change and it rolls out on its own; if a machine dies, I can rebuild it from scratch in minutes.

<details>
<summary>🤓 <b>For the technically curious</b> — the interesting bits</summary>

- **[Talos Linux](https://www.talos.dev/)** — a minimal, immutable OS with no SSH or shell; every node is defined entirely from [`talos/`](./talos/) and managed over an API.
- **[Flux](https://fluxcd.io/) GitOps** — the cluster reconciles itself to match this repo. Every change is a reviewed commit, never a manual `kubectl apply`.
- **[Cilium](https://cilium.io/) + BGP** — pods get routable IPs and LoadBalancer services are advertised straight to my UniFi router via BGP.
- **[External DNS UniFi Webhook](https://github.com/kashalls/external-dns-unifi-webhook)** — a webhook I wrote so DNS records publish directly to UniFi, no extra resolvers.
- **[Renovate](https://github.com/renovatebot/renovate)** — container images and Helm charts stay current through automated pull requests.
- **[VolSync](https://volsync.readthedocs.io/) + ZFS** — persistent data is snapshotted and backed up off-site, on top of a dedicated [TrueNAS box](#-hardware).

</details>

Built from onedr0p's [cluster template](https://github.com/onedr0p/flux-cluster-template) — you don't need a fancy multi-node setup to run your own. Come say hi in the [Home Operations](https://discord.gg/home-operations) Discord.

### Directory Helper

This repository uses the following layout for [Kubernetes](./kubernetes/).

```sh
📁 bootstrap
├── 📝 helmfile.yaml         # Helmreleases required to bootstrap Flux.
└── 📝 secrets.yaml.tpl      # Secrets required to bootstrap Flux.
📁 kubernetes
├── 📁 apps                  # Application configurations.
└── 📁 components            # Shared Kustomize components.
📁 talos
├── 📁 nodes                 # Per-node override configurations.
├── 📝 machineconfig.yaml.j2 # Base Talos configuration for all nodes.
└── 📝 talos.env             # Kubernetes and Talos version variables.
📁 unifi                     # Configuration files for UniFi
```

## ☁️ Cloud Dependencies

Most things are self-hosted, but a few critical pieces live in the cloud — to sidestep chicken-and-egg problems and stay reachable when the cluster is down.

| Service                                                 | Use                                                            | Cost           |
|---------------------------------------------------------|----------------------------------------------------------------|----------------|
| [1Password](https://1password.com/)                     | Secrets with [External Secrets](https://external-secrets.io/)  | ~$55/yr        |
| [Cloudflare](https://www.cloudflare.com/)               | Domains, Workers, Pages, and R2                                | ~$240/yr       |
| [Backblaze B2](https://www.backblaze.com/cloud-storage) | Backups                                                        | $1/m        |
| [GitHub](https://github.com/)                           | Hosting this repository and continuous integration/deployments | Free           |
| [Let's Encrypt](https://letsencrypt.org/)               | Issuing SSL Certificates with Cert Manager                     | Free           |
| [Migadu](https://migadu.com/)                           | Email Hosting                                                  | ~$20/yr        |
| [Pushover](https://pushover.net/)                       | Kubernetes Alerts and application notifications                | Free           |
| [UniFi Site Manager](https://unifi.ui.com)              | UniFi External Access Management                               | Free           |
|                                                         |                                                                | Total: ~$10/mo |

---

## 💻 Networking

Everything runs on a UniFi stack split into [VLANs](#networks--vlans) for isolation. The cluster hands out service IPs from a dedicated network and advertises them to the router over **BGP** (see [Cilium + BGP](#overview)), so a load-balanced app gets a real, routable address on my LAN — no port-forwarding or ingress hacks.

### Networking Diagram

```mermaid
flowchart LR
    classDef gateway fill:#163a1e,stroke:#27ae60,color:#fff
    classDef switch fill:#1e2a4a,stroke:#3498db,color:#fff
    classDef compute fill:#4a1e3a,stroke:#e74c3c,color:#fff
    classDef storage fill:#3a2a1e,stroke:#f39c12,color:#fff
    classDef ap fill:#1e3a2a,stroke:#2ecc71,color:#fff

    Internet(["The Internet"])

    Internet -- "2 Gbps ↓ / 350 Mbps ↑" --> UCG["UCG Fiber (Mystic)"]:::gateway

    UCG -- 2.5G --> FLEX["USW Flex 2.5G 8 PoE"]:::switch
    UCG -- 2.5G --> U7XG(["U7 Pro XG (Office)"]):::ap
    UCG -- 10G SFP+ --> AGG["USW Pro Aggregation"]:::switch

    AGG -- 10G SFP+ --> MAX["USW Pro Max 16 PoE"]:::switch
    AGG -- 20G LACP --> MS01["3x MS-01 (Main)"]:::compute
    AGG -- 10G --> PUDDLE["Puddle (NAS)"]:::storage

    MAX -- 1G --> U6LR(["U6-LR (Garage)"]):::ap
    MAX --> PDU["USP PDU Pro"]:::switch

    U7XG -. mesh .-> UDB["UDB Switch (Garage)"]:::switch
```

### Networks & Vlans

| Name                | VLAN | Description                                                                         |
|---------------------|------|-------------------------------------------------------------------------------------|
| Management          | 1    | Servers + Network Management                                                        |
| Devices             | 2    | Wireless Devices and Workstations                                                   |
| IoT                 | 3    | Small devices that *have the potential* to be compromised, so they don't get to talk to each other. |
| Services            | 4    | No DHCP — dedicated network for the cluster's BGP-advertised LoadBalancer IPs        |
| "I Don't Trust You" | 86   | Non-affiliated organization issued devices (school or work devices)                 |

### 🌐 DNS

I wrote [External DNS UniFi Webhook](https://github.com/kashalls/external-dns-unifi-webhook) so [External DNS](https://github.com/kubernetes-sigs/external-dns/) can publish the cluster's service and ingress hostnames straight to UniFi's built-in DNS — no extra resolvers or moving parts.

---

## 🔧 Hardware

### Compute

**Minisforum MS-01 × 3** · 96 GB RAM · Talos / Kubernetes

- **OS** — 1 TB Crucial NVMe
- **Local storage** — 2 TB Samsung PM9A3 U.2 NVMe
- **Out-of-band** — JetKVM

### Storage

**45HomeLab HL15** · 256 GB RAM · TrueNAS SCALE / ZFS

```sh
💾 Puddle                          # TrueNAS SCALE · 45HomeLab HL15 · 256 GB RAM
📦 boot-pool                       # single
└── 💿 1 TB Kingston NV3 NVMe
📦 puddle
├── 🗄️ data (raidz2-0)            # 6-wide RAIDZ2
│   ├── 💿 4 × 12 TB Seagate IronWolf
│   └── 💿 2 × 12 TB Seagate Exos 7E8
├── ⚡ cache (L2ARC)
│   └── 💿 2 × 1.92 TB Samsung PM9A3 NVMe
└── 🔁 spare
    └── 💿 1 × 12 TB Seagate IronWolf
🧊 unassigned
└── 💿 750 GB Intel Optane NVMe    # future SLOG
```

### Networking — UniFi

- **UCG Fiber** ("Mystic") — router · 2.5 G WAN
- **USW Pro Aggregation** — 10 G SFP+ aggregation switch
- **USW Pro Max 16 PoE** — 10 G SFP+ / PoE switch
- **USW Flex 2.5G 8 PoE** — 2.5 G PoE switch
- **USP PDU Pro** — rack PDU
- **U7 Pro XG** — Wi-Fi 7 AP (Office)
- **U6 LR** — Wi-Fi 6 AP (Garage)
- **UDB Switch** — workbench switch, wireless mesh (Garage)

### Power

**Eaton 5PX1500RT** — 1500 VA rackmount UPS

### IoT Gateways

- **Meshtastic MQTT Gateway** — LoRa mesh → MQTT
- **SMLIGHT SLZB-06M** — Zigbee / Matter gateway

---

## ⭐ Stargazers

<div align="center">

[![Star History Chart](https://api.star-history.com/svg?repos=waifulabs/infrastructure&type=Date)](https://star-history.com/#waifulabs/infrastructure&Date)

</div>

---

## Inspiration

Thanks to all the people who donate their time to the [Home Operations](https://discord.gg/home-operations) community.

Special thanks to: [ᗪєνιη ᗷυнʟ](https://github.com/onedr0p/home-cluster), [Bᴇʀɴᴅ Sᴄʜᴏʀɢᴇʀs](https://github.com/bjw-s-labs/k8s-gitops), and [Toboshii Nakama](https://github.com/toboshii/home-cluster) for their assistance.

Check out [kubesearch.dev](https://kubesearch.dev) to see what other users are running in their kubernetes home labs!
