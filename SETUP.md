# Set Up Your Own Copy — Full Guide

This guide stands up your **own** independent paper-trading bot from this code.
Everything here was learned the hard way — follow it in order and you'll skip the
traps.

> **You need your own everything.** Your own GitHub repo, your own Alpaca paper
> account, your own Slack, your own Claude Code cloud routines. Don't share a repo
> with someone else's bot — two bots pushing to the same `main` clobber each
> other's memory.

## Prerequisites (free)

- A **GitHub** account
- **Claude Code** with access to **cloud routines** (the scheduled-agent feature)
- An **Alpaca** account on **Paper Trading** (no real money)
- A **Slack** workspace you control (optional, for phone alerts)
- *(Optional)* a **Perplexity** API key — without it, research falls back to web search

---

## 1. Get your own copy of the code

1. On the GitHub repo page → **Use this template** → **Create a new repository**.
   Make it **Private**. Now you have `your-name/trading-bot`.
2. Clone it locally: `git clone <your repo url> ~/trading-bot && cd ~/trading-bot`

## 2. Reset the memory to a clean slate

The template carries the original owner's trade history. Wipe it so you start flat:

- `memory/TRADE-LOG.md` → keep only a Day 0 baseline:
  ```
  # Trade Log

  ## Day 0 — EOD Snapshot (pre-launch baseline)
  **Portfolio:** $100,000.00 | **Cash:** $100,000.00 (100%) | **Day P&L:** $0 | **Phase P&L:** $0

  No positions yet. Bot launches tomorrow.
  ```
- `memory/RESEARCH-LOG.md` and `memory/WEEKLY-REVIEW.md` → delete every dated entry,
  keep the template header at the top.
- Commit: `git add -A && git commit -m "reset memory" && git push`

## 3. Alpaca paper keys

1. Alpaca → switch to **Paper Trading** (top-left) → **Manage Accounts** → copy
   your **API Key** + **Secret** (endpoint should be `paper-api.alpaca.markets`).
2. `cp env.template .env` and fill in `ALPACA_API_KEY` and `ALPACA_SECRET_KEY`.
   *(`.env` is gitignored — never commit it.)*

## 4. Slack alerts (optional but recommended)

1. Make your **own** Slack workspace (slack.com) so it's not tied to work/school.
2. api.slack.com/apps → Create App → Incoming Webhooks → On → Add New Webhook →
   pick a channel → copy the `https://hooks.slack.com/services/...` URL.
3. In `.env`: set `NOTIFY_WEBHOOK_URL=<that url>` and `NOTIFY_WEBHOOK_TYPE=slack`.

## 5. Local smoke test

In Claude Code, in this folder:
- `/portfolio` → should print your paper account ($100k, flat).
- `/pre-market` → should write a research entry and (with a webhook) ping Slack.

If those work, the code + keys are good.

## 6. Install the Claude GitHub App

Install the Claude GitHub App on **your** repo only (least privilege). This lets
cloud routines clone and push.

## 7. Create the 5 cloud routines

Routines → New Routine, once per row. For **all five**, set the same:
- **Repo:** your repo, branch `main`
- **Environment** (shared): create one with these vars — `ALPACA_ENDPOINT`,
  `ALPACA_DATA_ENDPOINT`, `ALPACA_API_KEY`, `ALPACA_SECRET_KEY`, and (optional)
  `NOTIFY_WEBHOOK_URL`, `NOTIFY_WEBHOOK_TYPE=slack`. **Network access = Full.**
- ✅ **"Allow unrestricted git push"** ON (or commits silently fail)
- **Prompt:** paste the matching `routines/*.md` **verbatim**

| Routine | Cron (UTC) | Prompt file |
|---|---|---|
| pre-market | `0 11 * * 1-5` | routines/pre-market.md |
| market-open | `30 13 * * 1-5` | routines/market-open.md |
| midday | `0 17 * * 1-5` | routines/midday.md |
| daily-summary | `0 20 * * 1-5` | routines/daily-summary.md |
| weekly-review | `0 21 * * 5` | routines/weekly-review.md |

> Those crons are **UTC**, set for US market hours (Chicago, summer/CDT). The UI
> preview shows your local time. When US clocks change in November, add **+1 hour**.

## 8. Smoke-test in the cloud

Create pre-market first → **Run now** → confirm it commits to **`main`** (not a
`claude/*` branch) and pings Slack. If that works, build the other four.

---

## Gotchas (every one of these bit us — here's the fix baked in)

- **Cloud runs on a feature branch, not `main`.** The prompts push with
  `git push origin HEAD:main` so memory reaches the real `main`. Don't change it.
- **Routines run the PASTED prompt, not the repo file.** If you edit a
  `routines/*.md`, you must **re-paste** it into the routine for the change to go live.
  (Scripts, `CLAUDE.md`, and `memory/` *do* update automatically — cloned each run.)
- **Cron is UTC.** Convert carefully; remember DST.
- **Alpaca free data feed (IEX).** `ta.py` uses `sort=desc` to get recent bars; if
  it ever prints "TA unavailable", check your data subscription. It degrades safely.
- **Never commit `.env`.** It's gitignored. Use your own keys, your own webhook.

That's it. Same disciplined bot, your money (paper), your phone.
