# Security

EZQRContact is local-first. Cards, events, and history live in SQLite on
the device. There is no account, no API, and no server we operate.

## Report a vulnerability

Please **do not** open a public GitHub issue for a security bug.

Email **polsinelli@gmx.com** with:

- a short description
- steps to reproduce
- affected version / commit if you know it
- impact (data loss, QR injection, permission bypass, …)

You should get an acknowledgement within a few days. Fixes ship in the
next patch release when possible.

## What is in scope

- Reading or writing another app's data without OS permission
- Injecting vCard fields that break Contacts or execute unexpected URLs
- Bypassing the Contacts permission check and still writing the OS address book
- Path traversal when saving QR images or zip exports

## What is out of scope

- "The QR is huge because I embedded a photo" (by design we host a URL or drop PHOTO offline)
- Loss of data after uninstall (the DB is local)
- Social engineering of a person who scans an untrusted QR

## Crypto / network

The only network use is optional photo hosting so a vCard QR stays
scannable ([PRIVACY.md](PRIVACY.md)). No analytics SDK. No crash reporter.
