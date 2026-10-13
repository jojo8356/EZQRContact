# EZQRContact user guide

Local-first contact exchange on Android and iOS. Your cards stay on this
phone. Nothing is uploaded unless you put a photo online so the QR stays
small enough to scan.

In-app copy is French or English (Settings). This page is English.
French version: [guide-utilisateur.md](guide-utilisateur.md).

## First launch

1. Three onboarding screens explain the idea. Skip or finish.
2. On **Home**, three spotlight tips (create, scan, collection). Skip anytime.
   Replay from **Settings → Read guide**.
3. You land on **Home**.

## Create your card

1. Home → **VCard QR code**.
2. Fill at least a name. Phone, email, org, title, addresses are optional.
3. Optional: photo, primary color, logo, layout.
4. Generate. The card is stored in **Collection**.

The QR encodes a vCard (3.0 by default). Recipients do not need this app:
the system camera on iPhone or Android is enough.

**Photo:** the app never puts a raw multi-megabyte portrait inside the QR
(that makes it unscannable). Online, it hosts a small JPEG and writes a
`PHOTO;VALUE=URI:` line. Offline, the QR is text-only.

vCard **4.0** is a Settings toggle. Keep 3.0 unless you know the other
phone supports 4.0.

## Simple QR

Home → **Simple QR code**. Any text or URL. Saved in Collection next to
vCards.

## Scan a card

1. Home → **Scan a QR code** → **Scan QR Code**.
2. Grant camera if asked. Torch and camera flip sit on copper discs.
3. On a vCard, you get a result screen and the card is stored.
4. If **Offer my card in return** is on (Settings), you can share yours back.

## Import from a screenshot

Home → **Import a QR code** → pick an image. The decoder tries ML Kit then
ZXing (crop, unwarp, several scales). Useful when the QR is on a laptop
screen or a photo of a badge.

## Import phone contacts

Home → **Import contact** (one or many) or Collection → **Import all**.

Name duplicates already in Collection are skipped. Each imported contact
becomes an in-app card. The OS address book is **not** required for that.

## Collection

Navbar **Collection**. Search, open a card to share or delete it.

**Multi-select:** hold a card **more than two seconds**. Checkboxes appear.
You can select all, delete (confirm), or export the checked cards as the
same zip as Export all. Back or the close icon leaves select mode.

**Export all** writes `ezqr_collection.zip` at the zip root:

- `contacts.vcf` for vCards
- `text_<id>_<slug>.txt` and `.png` for simple QRs
- `index.txt`

**PDF** (orange FAB): pick cards, 1 per page or 2×2.

## History

Navbar **History**. Soft-deleted cards. Read-mostly.

## Settings

- Dark mode
- vCard 4.0
- Offer my card in return
- Language (English / Français)
- Read guide (replays the Home spotlight tour)
- Links to the project

## Privacy

| Data | Where |
|---|---|
| Cards, history | SQLite `qr_app.db` on the device |
| Language, onboarding, toggles | SharedPreferences |
| OS contacts | Written **only** if you grant Contacts. Deny it: the in-app QR still exists |
| Photo host | Used only when you add a photo **and** the phone is online |

No account. Uninstalling the app deletes the local database.

Full policy: [PRIVACY.md](../../PRIVACY.md). Photo hosting (catbox.moe,
then 0x0.st) runs only when you add a photo and the phone is online.

## Troubleshooting

**QR will not scan.** Shorten the card (drop the photo or go offline so
PHOTO is omitted). Prefer vCard 3.0. Reprint larger.

**Import from gallery finds nothing.** Crop closer to the code, or use
Scan. Screen photos of a laptop work better after a straight-on shot.

**Contacts not in the phone book.** Settings of the OS → app → Contacts
allowed. Generate again, or open the card and use the save action.

**Export zip missing text QRs.** Use Collection **Export all** (or
multi-select export), not the PDF FAB. PDF is layout only.

## Get the app

Build from source: [README](../../README.md). Releases: GitHub Releases
when a `v*.*.*` tag is pushed.
