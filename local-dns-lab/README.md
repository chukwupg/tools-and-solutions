# Local DNS Server for an Isolated Lab Network

A step-by-step guide to running your own DNS server with `dnsmasq` on an isolated virtual lab network, so your lab machines can reach each other by name (for example `ubuntu.lab`) with no internet or external DNS involved.

## Overview

On an isolated lab network, nothing answers DNS queries. Tools like `nslookup`, `ping host` and many security labs (DNS enumeration, log analysis, detection exercises) need name resolution to work. A small DNS server on one of your lab VMs solves this and gives you a place to practice DNS concepts and watch query logs.

This guide uses `dnsmasq` because it is lightweight, needs a single config file, and runs comfortably on a low-RAM host.

If you run into errors along the way, see [Troubleshooting: port 53 conflict](troubleshooting-port-53-conflict.md).

## Lab layout used in this guide

| Role | Machine | Address |
|---|---|---|
| DNS server | Ubuntu VM | `192.168.98.129` |
| Client | Kali VM | assigned on `192.168.98.0/24` |
| Client | Windows 10 VM | assigned on `192.168.98.0/24` |

- Hypervisor: VMware Workstation Pro
- Network: isolated `192.168.98.0/24`
- Domain used for lab names: `.lab`

Replace the addresses and names with your own.

## Requirements

- An Ubuntu VM with a static or reserved IP on the lab network
- `sudo` access on that VM
- Temporary internet access on the Ubuntu VM to install the package (see step 2)

## Step 1: Confirm the server's lab IP

On the Ubuntu VM:

```bash
ip -br a
```

Note the address on the lab interface (`192.168.98.129` here). The DNS server will listen on this address only.

## Step 2: Install dnsmasq

The package comes from the Ubuntu repositories, so the VM needs internet for this step. If your lab network is fully isolated, add a temporary NAT adapter to the VM, install the package, then remove the adapter.

```bash
sudo apt update
sudo apt install dnsmasq
```

## Step 3: See what already uses port 53

```bash
sudo ss -tulpn | grep :53
```

On Ubuntu you will normally see `systemd-resolved` listening on `127.0.0.53:53`. Leave it alone. The config below avoids a clash by binding dnsmasq to the lab IP only. If dnsmasq fails to start anyway, see the [troubleshooting note](troubleshooting-port-53-conflict.md).

## Step 4: Configure dnsmasq

Create a lab config file:

```bash
sudo nano /etc/dnsmasq.d/lab.conf
```

```
# Listen only on the lab interface address
listen-address=192.168.98.129
bind-interfaces

# Do not forward queries to outside DNS servers (isolated lab)
no-resolv

# Do not forward plain names without a domain
domain-needed

# Lab hostnames
address=/ubuntu.lab/192.168.98.129
```

Add one `address=/name.lab/IP` line for each machine you want to resolve.

`address=` only creates the forward (name to IP) record. If you also want reverse lookups (IP to name), use `host-record` instead, which creates both:

```
host-record=ubuntu.lab,192.168.98.129
```

Check the config for mistakes before starting the service:

```bash
sudo dnsmasq --test
```

## Step 5: Start the service and make it persistent

```bash
sudo systemctl restart dnsmasq
sudo systemctl enable dnsmasq
sudo systemctl status dnsmasq
```

If `ufw` is active on the Ubuntu VM, allow DNS from the lab network:

```bash
sudo ufw allow from 192.168.98.0/24 to any port 53
```

## Step 6: Point the other VMs at the DNS server

### Kali (NetworkManager)

Find the connection name, then set the DNS server and stop it taking DNS from DHCP:

```bash
nmcli con show
sudo nmcli con mod "<connection-name>" ipv4.dns 192.168.98.129 ipv4.ignore-auto-dns yes
sudo nmcli con up "<connection-name>"
```

### Windows 10 (PowerShell as Administrator)

```powershell
Get-NetAdapter
Set-DnsClientServerAddress -InterfaceAlias "<adapter-name>" -ServerAddresses 192.168.98.129
```

## Step 7: Verify

From any client VM:

```bash
nslookup ubuntu.lab 192.168.98.129
nslookup ubuntu.lab
```

Both should return `192.168.98.129`. The second command confirms the client is using your DNS server by default.

On the DNS server, you should see dnsmasq on the lab address:

```bash
sudo ss -tulpn | grep :53
```

## Optional: log queries

Useful for DNS and detection exercises. Add this line to `lab.conf`:

```
log-queries
```

Restart dnsmasq, then watch queries arrive:

```bash
sudo systemctl restart dnsmasq
sudo journalctl -u dnsmasq -f
```

## Notes

- Because of `no-resolv`, names outside your lab will not resolve. To allow internet names, remove `no-resolv` and add an upstream server such as `server=8.8.8.8` (this requires the DNS server VM to have internet access).
- Keep the DNS server VM's IP fixed. If it changes, clients lose name resolution.
- Back up `lab.conf` before experimenting.

## Troubleshooting

- [Challenge and fix: `nslookup` refused and dnsmasq vs systemd-resolved on port 53](troubleshooting-port-53-conflict.md)

## Author

**CHUKWU PRAISEGOD**  

**Follow my journey: [X](https://x.com/chukwupg) | [LinkedIn](https://linkedin.com/in/chukwupg)**

## License

MIT

See the `LICENSE` file.