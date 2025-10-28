<div align="center">

# Kashall's Infrastructure

[![Discord](https://img.shields.io/discord/673534664354430999?style=for-the-badge&label&logo=discord&logoColor=white&color=blue)](https://discord.gg/home-operations)&nbsp;&nbsp;
[![Talos](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fquery%3Fformat%3Dendpoint%26metric%3Dtalos_version&style=for-the-badge&logo=talos&logoColor=white&color=blue&label=%20)](https://www.talos.dev/)&nbsp;&nbsp;
[![Kubernetes](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fquery%3Fformat%3Dendpoint%26metric%3Dkubernetes_version&style=for-the-badge&logo=kubernetes&logoColor=white&color=blue&label=%20)](https://www.talos.dev/)&nbsp;&nbsp;
[![Renovate](https://img.shields.io/github/actions/workflow/status/kashalls/home-cluster/renovate.yaml?branch=main&label=&logo=renovatebot&style=for-the-badge&color=blue)](https://github.com/kashalls/home-cluster/actions/workflows/renovate.yaml)

[![Age-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fquery%3Fmetric%3Dcluster_age_days&style=flat-squaree&label=Age)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;&nbsp;
[![Uptime-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fquery%3Fmetric%3Dcluster_uptime_days&style=flat-square&label=Uptime)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;&nbsp;
[![Active-Alerts](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fquery%3Fmetric%3Dprometheus_active_alerts&style=flat-square&label=Firing%20Alerts)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;&nbsp;
[![Node-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fquery%3Fmetric%3Dcluster_node_count&style=flat-square&label=Nodes)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;&nbsp;
[![Pod-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fquery%3Fmetric%3Dcluster_pods_running&style=flat-square&label=Pods&color=green)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;&nbsp;
[![CPU-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fquery%3Fmetric%3Dcluster_cpu_usage&style=flat-square&label=CPU)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;&nbsp;
[![Power-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.ok8.sh%2Fquery%3Fmetric%3Dcluster_power_usage&style=flat-square&label=Power)](https://github.com/kashalls/kromgo/)

</div>

## What is this?

This is the repository I use to version control my kubernetes cluster I deploy and maintain at home. I currently use [Talos](https://www.talos.dev/) to provide a secure, minimal and immutable environment for Kubernetes. Previous iterations of this repository relied on Debian-based Operating Systems which can lead unwanted changes in the base system.

## How did you do this?

Thanks to [onedr0p](https://github.com/onedr0p), there is the [cluster template](https://github.com/onedr0p/flux-cluster-template) that allows you to easily get started with your own kubernetes cluster at home. You don't need to have multiple computers or a fancy setup to get one working.

If you're interested, you can also join the community [Home Operations](https://discord.gg/home-operations). Several people are involved daily and it makes for some interesting conversations.

### Directory Helper

This repository uses the following layout for [Kubernetes](./kubernetes/).

```sh
📁 bootstrap
├── 📝 helmfile.yaml # Helmreleases required to run bootstrap flux.
└── 📝 secrets.yaml.tpl # Secrets required to bootstrap flux.
📁 kubernetes
├── 📁 apps # Per-cluster application-specific configurations.
├── 📁 components # Flux & Talos configurations for setting up the cluster.
└── 📁 flux # Flux configuration, application repositories and more.
📁 talos
├── 📁 nodes # Override configurations for each individual node.
├── 📝 machineconfig.yaml.j2 # Base configuration for all nodes.
└── 📝 talos.env # Kubernetes and Talos Version Variables
📁 unifi # Configuration files for UniFi
📝 kubeconfig
📝 talosconfig
```

## ☁️ Cloud Dependencies

While most of my infrastructure and workloads are self-hosted I do rely upon the cloud for certain key parts of my setup. This saves me from having to worry about two things. (1) Dealing with chicken/egg scenarios and (2) services I critically need whether my cluster is online or not.

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

### Networking Diagram

```mermaid
flowchart LR
    A[["#quot;The Internet#quot;"]] -- 2Gbps ↓ 350Mbps  ↑ --> B("UXG Max");
    B -- 2.5Gbps ↕ --> C("USW Flex 2.5G 8 PoE")
    C -- 2.5Gbps ↕ --> D["U6 LR (Home Network)"]
    C -- 10Gbps ↕ --> E("USW Aggregation")
    E -- 10Gbps ↕ --> F["UDM Pro SE (Lab Network)"]
    F -- 10Gbps ↕ --> G("USW Pro Max 16")
    E -- 10Gbps ↕ --> H["3x MS-01 (Talos)"]
    E -- 10Gbps ↕ --> I["1x Storage (TrueNAS)"]
```

### Networks & Vlans

| Name                | VLAN | Description                                                                         |
|---------------------|------|-------------------------------------------------------------------------------------|
| Management          | 1    | Servers + Network Management                                                        |
| Devices             | 2    | Wireless Devices and Workstations                                                   |
| IoT                 | 3    | Small devices that *have the potential* to be compromised, so they don't get to talk to each other. |
| Services            | 4    | No DHCP, Simply a network for Cluster BGP                                           |
| "I Don't Trust You" | 86   | Non-affiliated organization issued devices (school or work devices)                 |

### 🌐 DNS

UniFi released a new feature update with UniFi routers that allow you to create custom dns records to be served to the whole network. I wrote [External DNS Unifi Webhook](https://github.com/kashalls/external-dns-unifi-webhook) to allow [External DNS](https://github.com/kubernetes-sigs/external-dns/) to gather service and ingress hosts from my clusters and deploy the records to my routers local dns server without any extra local resolvers or moving parts.

---

## 🔧 Hardware

<details>
  <summary>Click to see the rack!</summary>
  Updated 05/25/2024

  <img src="https://owo.whats-th.is/2drDDRN.jpg" align="center" width="200px" alt="rack"/>
</details>

### Office Rack

| Device                  | Count | OS Disk Size | Data Disk Size       | Ram  | Operating System | Purpose           |
|-------------------------|-------|--------------|----------------------|------|------------------|-------------------|
| UXG Max                 | 1     | -            | -                    | -    | UniFi OS         | Router            |
| UCK G2 Plus             | 1     | -            | -                    | -    | UniFi OS         | Controller        |
| USW Flex 2.5G 8 PoE     | 1     | -            | -                    | -    | UniFi OS         | Office Switch
| U6-LR                   | 1     | -            | -                    | -    | -                | Office AP         |
| Airgradient             | 1     | -            | -                    | -    | -                | Dining Room AP    |

### Server Rack

| Device                  | Count | OS Disk Size | Data Disk Size       | Ram  | Operating System | Purpose            | Network
|-------------------------|-------|--------------|----------------------|------|------------------|--------------------|----------|
| UDM Pro                 | 1     | -            | -                    | -    | UniFi OS         | Router             | Lab      |
| USW 16 Pro Max          | 1     | -            | -                    | -    | UniFi OS         | Switching          | Lab      |
| USW Aggregation         | 1     | -            | -                    | -    | UniFi OS         | Office Aggregation | Office   |
| U7-Pro                  | 1     | -            | -                    | -    | -                | Lab AP             | Lab      |
| UAP-AC-Pro              | 1     | -            | -                    | -    | -                | Dining Room AP     | Lab      |
| USP-PDU-Pro             | 1     | -            | -                    | -    | -                | Rack PDU           | Lab      |
| MS-01                   | 3     | 1TB NVMe     | 2TB PM9A3 U.2        | 96GB | Talos            | Main Cluster       | Office
| Fran                    | 1     | 2x1TB SSD    | 5x8TB (raidz2)       | 64GB | Debian           | Storage            | Office
| JetKVM                  | 1     | 16GB (Flash) | -                    | -    | JetKVM           | Network KVM        | Lab
| APC Back-Ups 1500       | 1     | -            | -                    | -    | -                | UPS                | -
| Meshtastic MQTT GW      | 1     | -            | -                    | -    | -                | MQTT GW            | Lab

---

## ⭐ Stargazers

<div align="center">

[![Star History Chart](https://api.star-history.com/svg?repos=kashalls/home-cluster&type=Date)](https://star-history.com/#kashalls/home-cluster&Date)

</div>

---

## Inspiration

Thanks to all the people who donate their time to the [Home Operations](https://discord.gg/home-operations) community.

Special thanks to: [ᗪєνιη ᗷυнʟ](https://github.com/onedr0p/home-cluster), [Bᴇʀɴᴅ Sᴄʜᴏʀɢᴇʀs](https://github.com/bjw-s-labs/k8s-gitops), and [Toboshii Nakama](https://github.com/toboshii/home-cluster) for their assistance.

Check out [kubesearch.dev](https://kubesearch.dev) to see what other users are running in their kubernetes home labs!
