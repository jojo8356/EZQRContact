# Privacy

EZQRContact is built so your cards live on **your phone**. There is no
account, no analytics SDK, and no server we operate.

This page is the policy for the open-source app. If you ship a fork, you
are responsible for your own policy.

## What we store on the device

| Data | Where | Why |
|---|---|---|
| vCards and simple QRs | SQLite `qr_app.db` | Collection, History, PDF, zip export |
| Language, onboarding, dark mode, vCard 4, reciprocal swap | SharedPreferences | Settings |
| Rendered QR PNGs | app documents directory | Share / export |

Uninstalling the app deletes this data. There is no cloud restore.

## Contacts permission

Creating a card **always** writes the in-app QR.

The OS address book is updated **only** if you grant Contacts. If you
deny it, the card still exists in Collection. Nothing is copied off the
phone to “make up for” a denied permission.

## Network

Most flows work offline (create, scan, import from gallery, Collection,
PDF, zip).

The **only** automatic network use is optional **photo hosting** when
you attach a portrait to a vCard **and** the device has internet:

1. The photo is resized and compressed.
2. The app uploads it anonymously to [catbox.moe](https://catbox.moe)
   (`reqtype=fileupload`, no `userhash`).
3. If that fails, it tries [0x0.st](https://0x0.st).
4. The QR payload contains `PHOTO;VALUE=URI:https://…`, not the raw
   bytes (inline base64 makes the QR unscannable).

If the phone is offline, PHOTO is omitted and the QR is text-only.

Those hosts are third parties with their own terms. Do not put a photo
in a vCard if you cannot accept that.

Scan, gallery import, and zip/PDF export do **not** upload.

## What we do not collect

- No sign-in
- No crash reporter
- No advertising ID
- No telemetry

## Recipients

Anyone who scans your QR receives the vCard fields you put in it
(name, phones, email, org, and the photo URL if present). That is the
point of a business card. They do not need this app.

## GDPR

We are not a data controller for your contacts: we never receive them.
If you use the optional photo host, that host processes the image file
you chose to upload.

## Contact

Questions or deletion help (for a fork you do not control, we cannot
wipe a phone we do not have): **polsinelli@gmx.com**.
