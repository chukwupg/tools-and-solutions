#!/usr/bin/env python3
# Safe static triage of an .eml: reads only, never runs or saves attachments
import sys, re, hashlib, email
from email import policy

with open(sys.argv[1], "rb") as f:
    msg = email.message_from_binary_file(f, policy=policy.default)

print("== KEY HEADERS ==")
for h in ["From", "To", "Subject", "Date", "Return-Path", "Reply-To", "Message-ID", "X-Originating-IP"]:
    print(f"{h}: {msg.get(h)}")

print("\n== AUTHENTICATION ==")
found = False
for h in ["Authentication-Results", "Received-SPF", "ARC-Authentication-Results"]:
    for v in msg.get_all(h, []):
        found = True
        print(f"{h}: {' '.join(str(v).split())[:400]}")
for v in msg.get_all("DKIM-Signature", []):
    found = True
    print("DKIM-Signature:", " ".join(str(v).split())[:200])
if not found:
    print("(no authentication headers present)")

print("\n== RECEIVED (top = last hop; read bottom to top) ==")
for i, v in enumerate(msg.get_all("Received", []), 1):
    print(f"[{i}] {' '.join(str(v).split())[:250]}")

print("\n== URLS (defanged) ==")
urls = set()
for part in msg.walk():
    if part.get_content_type() in ("text/plain", "text/html"):
        try:
            text = part.get_content()
        except Exception:
            continue
        urls.update(re.findall(r'https?://[^\s"\'<>)\]]+', text))
for u in sorted(urls):
    print(u.replace("http", "hxxp").replace(".", "[.]"))

print("\n== ATTACHMENTS ==")
for part in msg.walk():
    name = part.get_filename()
    if name:
        data = part.get_payload(decode=True) or b""
        print(f"{name} | {part.get_content_type()} | {len(data)} bytes")
        print("  SHA256:", hashlib.sha256(data).hexdigest())
