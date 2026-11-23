# Lab Fixes and Tools

Tools, setup guides and troubleshooting notes from my cybersecurity home lab work. Each entry documents what I built or set up, why, how to use it, and the problems I hit along the way. If you are working on something similar, you are welcome to use or adapt any of it.

Maintained by [Chukwu PraiseGod](https://github.com/chukwupg) · [Portfolio](https://chukwupg.github.io) · [Substack](https://chukwupg.substack.com) · [X](https://x.com/chukwupg) · [LinkedIn](https://linkedin.com/in/chukwupg) 

## Contents

| Entry | Type | What it covers |
|---|---|---|
| [Windows10-Lab-Debloater](Windows10-Lab-Debloater/) | Tool (PowerShell) | Conservative removal of selected preinstalled Windows 10 apps to lighten resource-constrained lab VMs, with preview mode and logging |
| [phishing-email-triage](phishing-email-triage/) | Tool (Python) | Read-only analysis of a suspicious `.eml` file: key headers, authentication results, mail path, defanged links and attachment hashes, without opening the email in a mail client |
| [local-dns-lab](local-dns-lab/) | Guide + troubleshooting | Setting up a local DNS server with dnsmasq on an isolated lab network, including the fix for the port 53 conflict with systemd-resolved |

## Repo layout

```text
lab-fixes/
├── README.md
├── LICENSE
├── template.md                # template for contributors
├── Windows10-Lab-Debloater/   # PowerShell script + its own README
├── phishing-email-triage/     # Python script + its own README
└── local-dns-lab/             # setup guide + troubleshooting notes
```

Each folder has its own README that states what it was built and tested on, so check that before assuming it applies to your setup.

## Safety

Scripts here change system settings, remove software, or handle potentially malicious files. Run them in a virtual machine, take a snapshot first, and read a script before you run it. Analyse suspicious samples only in an isolated lab VM. Use everything only on systems and data you own or are authorized to test.

## Contributing

Found a better approach, or a case where one of these fails? Open an issue with your OS or tool version, the exact error, and what you tried. Pull requests are welcome; follow [template.md](template.md) for new entries.

## License

[MIT](LICENSE) 

Use, modify and share freely, with attribution.