# Phishing Email Triage Script

A small, read-only Python script that helps a defender look at a suspicious `.eml` file safely. It pulls out the key headers, the authentication results, the mail path, the links (defanged) and the attachment hashes, so you can start an investigation without opening the email in a mail client.

Written to aid my workflow during my DG Interns Hub Cybersecurity Internship (Week 5) for analysing public phishing samples in an isolated lab VM.

Link to Repo: [phishing-analysis](https://github.com/chukwupg/dg-interns-hub-cybersecurity-internship/tree/main/week-5/Findings/phishing-analysis)

## What it does

| Section | What it prints |
|---|---|
| Key headers | From, To, Subject, Date, Return-Path, Reply-To, Message-ID, X-Originating-IP |
| Authentication | Authentication-Results, Received-SPF, ARC results and DKIM-Signature (shortened), or a note if none are present |
| Received chain | Every `Received` header, in file order (top is the last hop, so read it bottom to top) |
| URLs | Links found in the plain-text and HTML parts, defanged (`hxxps://example[.]com`) |
| Attachments | File name, content type, size and SHA256 hash of each attachment |

## What it does NOT do

- It does **not** open, save, run or decode attachments to disk. It hashes them in memory only.
- It does **not** visit any link or make any network connection. It uses only the Python standard library.
- It does **not** modify, delete or write any file. It only reads the `.eml` you give it.
- It does **not** decide whether an email is malicious. It gives you the evidence, and you make the call.
- It does **not** check SPF, DKIM or DMARC itself. It shows the results already written into the headers by the receiving server.

The script is short and has no obfuscation. Read it before you run it, as you should with any tool you download.

## Requirements

- Python 3 (standard library only, nothing to install)
- A `.eml` file to analyse

## Usage

```bash
python3 triage.py sample.eml
```

Redirect the output to a file if you want to keep it:

```bash
python3 triage.py sample.eml > sample-triage.txt
```

## Example output (illustrative, made-up values)

```
== KEY HEADERS ==
From: Example Support <support@example.com>
To: user@example.org
Subject: Your account needs attention
Date: Mon, 01 Jan 2026 10:00:00 +0000
Return-Path: bounce@mailer.example.net
Reply-To: None
Message-ID: <abc123@mailer.example.net>
X-Originating-IP: None

== AUTHENTICATION ==
Authentication-Results: spf=fail ...; dkim=none; dmarc=fail ...

== RECEIVED (top = last hop; read bottom to top) ==
[1] from mx.example.org ...
[2] from mailer.example.net (203.0.113.10) ...

== URLS (defanged) ==
hxxps://login[.]example[.]net/verify

== ATTACHMENTS ==
invoice.pdf | application/pdf | 18354 bytes
  SHA256: <sha256 hash>
```

## How to read the output

| Look at | Red flag |
|---|---|
| From vs Return-Path vs Reply-To | Different domains, or a display name that does not match the address |
| Authentication | SPF, DKIM or DMARC fail or none. A pass is not proof the email is safe |
| Received chain | The bottom hop is the origin. Check it is not an unexpected hosting provider |
| Message-ID | A domain that does not match the sender |
| URLs | Redirect or tracking links, look-alike domains, odd characters |
| Attachments | Unexpected files. Search the **hash** on a reputation site instead of opening or uploading the file |

## Suggested workflow

1. Run the script on the sample inside an isolated VM.
2. Check the domains, IPs and hashes with free tools such as VirusTotal, urlscan.io, AbuseIPDB and AlienVault OTX. Search by hash and avoid uploading private files.
3. Decode any redirect or encoded links with a tool such as [CyberChef](https://gchq.github.io/CyberChef/), and never click them.
4. Record your findings with defanged indicators and give a verdict (benign, suspicious or malicious).

## Limitations

- Long header lines are shortened (Received lines to 250 characters, authentication lines to 400), so very long headers are cut off. Use the raw `.eml` for the full text.
- It reads links only from the plain-text and HTML parts. It does not render the page or read link text, so a link's visible text is not shown.
- HTML entities are not decoded, so the same link can appear twice (once with `&amp;`).
- It does not decode redirect links (for example search-engine redirect links with a base64 value).
- Attachments without a file name are not listed.
- It does not print the message body.

## Safe handling

- Analyse samples only inside an isolated VM, and never open attachments from untrusted emails.
- Keep real emails out of public repositories. Do not commit `.eml` files.
- Defang URLs and IPs in your notes and reports.
- Use the script only on samples you are allowed to analyse, such as public datasets like the [phishing_pot](https://github.com/rf-peixoto/phishing_pot) repository, or your own organisation's reported emails.

## Author

**CHUKWU PRAISEGOD**  

**Follow my journey: [X](https://x.com/chukwupg) | [LinkedIn](https://linkedin.com/in/chukwupg)**

## License

MIT

See the `LICENSE` file.
