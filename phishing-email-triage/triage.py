#!/usr/bin/env python3
"""
triage.py - safe, read-only triage of a suspicious email (.eml file)

What it does:
  Prints key headers, authentication results, the Received chain, links
  (defanged) and the SHA256 hash of each attachment.

What it does NOT do:
  - It does not open, save or run attachments (they are hashed in memory only).
  - It does not visit links or make any network connection.
  - It does not modify, delete or write any file.
  - It uses only the Python standard library.

Usage:
  python3 triage.py sample.eml
  python3 triage.py sample.eml > sample-triage.txt

Run it only on samples you are allowed to analyse, inside an isolated VM.
Author: Chukwu PraiseGod | License: MIT
"""

import sys
import re
import hashlib
import email
from email import policy

KEY_HEADERS = ["From", "To", "Subject", "Date", "Return-Path",
               "Reply-To", "Message-ID", "X-Originating-IP"]
AUTH_HEADERS = ["Authentication-Results", "Received-SPF",
                "ARC-Authentication-Results"]


def usage():
    print("Usage: python3 triage.py <file.eml>")
    print("Reads the email only. It does not open attachments or visit links.")


def load_message(path):
    try:
        with open(path, "rb") as f:
            return email.message_from_binary_file(f, policy=policy.default)
    except FileNotFoundError:
        sys.exit(f"Error: file not found: {path}")
    except IsADirectoryError:
        sys.exit(f"Error: {path} is a folder, not an .eml file")
    except PermissionError:
        sys.exit(f"Error: no permission to read {path}")
    except Exception as e:
        sys.exit(f"Error: could not parse {path}: {e}")


def flat(value, limit):
    """Collapse whitespace and shorten long header values."""
    return " ".join(str(value).split())[:limit]


def defang(url):
    return url.replace("http", "hxxp").replace(".", "[.]")


def main():
    if len(sys.argv) != 2 or sys.argv[1] in ("-h", "--help"):
        usage()
        sys.exit(0 if len(sys.argv) == 2 else 1)

    msg = load_message(sys.argv[1])

    print("== KEY HEADERS ==")
    for h in KEY_HEADERS:
        print(f"{h}: {msg.get(h)}")

    print("\n== AUTHENTICATION ==")
    found = False
    for h in AUTH_HEADERS:
        for v in msg.get_all(h, []):
            found = True
            print(f"{h}: {flat(v, 400)}")
    for v in msg.get_all("DKIM-Signature", []):
        found = True
        print("DKIM-Signature:", flat(v, 200))
    if not found:
        print("(no authentication headers present)")

    print("\n== RECEIVED (top = last hop; read bottom to top) ==")
    for i, v in enumerate(msg.get_all("Received", []), 1):
        print(f"[{i}] {flat(v, 250)}")

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
        print(defang(u))

    print("\n== ATTACHMENTS ==")
    for part in msg.walk():
        name = part.get_filename()
        if name:
            data = part.get_payload(decode=True) or b""
            print(f"{name} | {part.get_content_type()} | {len(data)} bytes")
            print("  SHA256:", hashlib.sha256(data).hexdigest())


if __name__ == "__main__":
    main()
