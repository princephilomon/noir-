# Noir — Live Ordering System: Setup Guide

This package has 3 screens, all connected through one shared database:

| File | Used by | What it does |
|---|---|---|
| `customer.html` | Guest's phone (via QR code) | Browse menu, place order |
| `staff/kitchen.html` | Kitchen staff | See new orders live, mark preparing → ready |
| `staff/floor.html` | Waiters | See ready orders, mark served, take payment |

All three sync **instantly** through Supabase — no refreshing, no polling.

---

## Step 1 — Create your free Supabase project

1. Go to https://supabase.com → sign up (free tier is plenty for one restaurant)
2. Click **New Project**, give it a name (e.g. "noir-orders"), set a database password, pick the region closest to the restaurant
3. Wait ~2 minutes for it to provision

## Step 2 — Create the orders table

1. In your Supabase project, open the **SQL Editor** (left sidebar)
2. Click **New query**
3. Open `supabase-schema.sql` from this package, copy everything, paste it in, click **Run**
4. You should see "Success. No rows returned" — that means the `orders` table now exists

## Step 3 — Get your API credentials

1. In Supabase, go to **Project Settings** (gear icon) → **API**
2. Copy two values:
   - **Project URL** (looks like `https://abcdefgh.supabase.co`)
   - **anon public** key (a long string under "Project API keys")

## Step 4 — Paste credentials into config.js

Open **both** `config.js` files (one at the root, one inside `staff/`) and replace:

```js
const SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL";
const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_PUBLIC_KEY";
```

with your actual values from Step 3. Save both files — they need to match.

## Step 5 — Test it locally

You can't just double-click these HTML files (browsers block some features when opened as `file://`). Instead, run a tiny local server:

```bash
# From inside the noir-system folder:
python3 -m http.server 8000
```

Then open in your browser:
- Customer menu: `http://localhost:8000/customer.html?table=12`
- Kitchen screen: `http://localhost:8000/staff/kitchen.html`
- Floor screen: `http://localhost:8000/staff/floor.html`

Place a test order on the customer page — it should appear on the Kitchen screen within a second or two. Mark it "Ready" — it should then appear on the Floor screen automatically.

## Step 6 — Deploy for real use

For the actual restaurant, host these files somewhere public so QR codes work from any phone. Easiest free options:
- **Vercel** or **Netlify** — drag-and-drop deploy, free tier, gives you a real URL
- Once deployed, each table's QR code points to: `https://yoursite.com/customer.html?table=N` (swap N for each table number)

## How the status flow works

```
Customer places order
        ↓
   [Kitchen sees it: "New Orders"]
        ↓ (tap "Start Preparing")
   [Kitchen: "Preparing"]
        ↓ (tap "Mark Ready")
   [Kitchen: "Ready" AND Floor: "Ready to Serve"]  ← appears on BOTH screens
        ↓ (waiter taps "Delivered to Table")
   [Floor: "Awaiting Payment"]
        ↓ (waiter taps "Paid — Cash" or "Paid — Online")
   [Order complete, clears from all boards]
```

## Notes

- The current setup allows open read/write access to the `orders` table (fine for an internal single-restaurant tool). Before scaling to multiple locations or exposing more broadly, add proper authentication.
- Phone vibration alerts (`navigator.vibrate`) work on Android Chrome; iOS Safari does not support this API, so kitchen/floor staff on iPhones will rely on the visual toast notification and on-screen badge counts instead.
- Everything here is one self-contained HTML file per screen — easy to hand off, easy to host anywhere, no build step required.
