# Lab DNS: `nslookup` refused and dnsmasq vs systemd-resolved on port 53

**Tested on:** VMware Workstation Pro, Ubuntu VM at 192.168.98.129, isolated `192.168.98.0/24`

**Area:** Virtual lab

## Symptom
- `nslookup <host> 192.168.98.129` fails with "connection refused", because nothing in the lab network is answering DNS.
- After installing `dnsmasq`, it fails to start because port 53 is already in use.

## Cause
Nothing was running a DNS server on the address the VMs were pointed at. Once dnsmasq is installed, it tries to bind port 53 on all interfaces, but Ubuntu's `systemd-resolved` already holds a stub listener on `127.0.0.53:53`.

## Fix
Install dnsmasq on the Ubuntu VM and make it listen only on the lab interface's IP, which avoids the clash.

```bash
sudo apt install dnsmasq
sudo nano /etc/dnsmasq.d/lab.conf
```

Replace the config file with these lines (backup first)
```
listen-address=192.168.98.129
bind-interfaces
address=/ubuntu.lab/192.168.98.129
```
Restart 
```bash
sudo systemctl restart dnsmasq
```

Point your other VMs at `192.168.98.129` as their DNS server.

## Verify
```bash
sudo ss -tulpn | grep :53
nslookup ubuntu.lab 192.168.98.129
```
You should see dnsmasq on `192.168.98.129:53` and `systemd-resolved` still on `127.0.0.53:53`, and the lookup should return `192.168.98.129`.

## Notes
- Add a custom `address=/name.lab/IP` line for each lab host you want to resolve.
- If you also need internet names to resolve through dnsmasq, add an upstream `server=<public-dns-server>` line (this requires the DNS server VM to have internet access).
- While troubleshooting I added a NAT adapter to Ubuntu for internet access used for the installation step. Remove it afterward if you want the lab fully isolated.
