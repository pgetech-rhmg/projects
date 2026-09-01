# EPIC GitHub App — Org Admin Setup

---

## Part 1 — Create the app (do this once)

**Org Settings → Developer settings → GitHub Apps → New GitHub App**

1. **Name / homepage URL** — anything identifiable, e.g. `EPIC Pipeline`. (Cosmetic.)

2. **Webhook** — **uncheck "Active."**
   The app does not need webhook events. (EPIC's existing push-trigger webhook is a *separate* service connection — leave it alone.)

3. **Repository permissions** — set exactly these, nothing more:
   - **Contents:** Read-only
   - **Commit statuses:** Read and write
   - **Metadata:** Read-only *(auto-selected, required)*

   > This is the whole grant. The app can read code and post commit statuses — it **cannot** push, delete, or change settings.

4. **Where can this GitHub App be installed?** → **Any account**
   (The app is owned by `pgetech`, but the EPIC team will also install it on a second org — this setting is required to allow that.)

5. Click **Create GitHub App**.

6. On the app's settings page, **Generate a private key**. This downloads a `.pem` file.
   ⚠️ **This private key is the crown jewel** — anyone holding it can mint access tokens for every install of this app. Hand it over securely (see "What to send back"), don't email it. If it ever leaks, regenerate it here — no reinstall needed.

7. Note the **App ID** shown near the top of the settings page.

---

## Part 2 — Install the app on `pgetech`

From the app's settings page: **Install App** → select **`pgetech`** →

- Choose **All repositories** *(not "Only select repositories")*.
  This covers every current **and future** repo automatically, so new apps onboard with zero admin action.
- Click **Install**.

After installing, note the **Installation ID** — it's the number in the install's settings URL:
`https://github.com/organizations/pgetech/settings/installations/<INSTALLATION_ID>`

---

## What to send back to the EPIC team

Three things:

1. **App ID** — a number
2. **Private key** — the `.pem` file *(send securely — ideally dropped straight into the secret store, not over email/chat)*
3. **Installation ID** — for the `pgetech` install
