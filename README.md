# Trading Bot — Autonomous Alpaca Paper Trader

An autonomous swing-trading agent built on Claude Code. **Claude *is* the bot** —
there's no separate Python process. Five scheduled cloud routines fire each
weekday; each one spins up a fresh container, clones this repo, reads its memory,
pulls live account state, decides, places **paper** orders if warranted, writes
new memory, commits to git, and notifies you.

It is **stateless between runs** — all memory lives as markdown files in this
repo. If it's not committed to `main`, it didn't happen.

> **Paper trading.** This uses Alpaca's paper API (`paper-api.alpaca.markets`).
> No real money is at risk. The goal is to learn a disciplined process and try
> to beat the S&P 500.

## How it differs from the original guide

- **Paper, not live** — `scripts/alpaca.sh` defaults to the paper endpoint.
- **Research** — `scripts/perplexity.sh` is optional; with no key it exits 3 and
  the agent falls back to native WebSearch.
- **Notifications** — `scripts/notify.sh` posts to a Discord/Slack webhook, or
  appends to `NOTIFICATIONS.md` when no webhook is set.

## Layout

```
CLAUDE.md            # Agent rulebook (auto-loaded every session)
env.template         # Copy to .env for local use (gitignored)
.claude/commands/    # Ad-hoc slash commands for local testing
routines/            # Cloud routine prompts (the production path)
scripts/             # API wrappers — the only thing that touches the outside world
memory/              # The agent's persistent state (committed to main)
```

## The strategy (hard rules — non-negotiable)

- No options, ever. Stocks only.
- Max 5-6 open positions, max 20% equity each.
- Max 3 new trades per week. 75-85% deployed.
- 10% trailing stop on every position as a real GTC order.
- Cut losers at -7%. Tighten trail to 7% at +15%, to 5% at +20%.
- Never within 3% of current price. Never move a stop down.
- Exit a sector after 2 consecutive failed trades. Patience > activity.

## Quick start

1. **Sign up for Alpaca**, switch to **Paper Trading**, generate paper API keys.
2. `cp env.template .env` and fill in `ALPACA_API_KEY` / `ALPACA_SECRET_KEY`.
   (Perplexity + webhook are optional — leave blank to use the free fallbacks.)
3. **Local smoke test:** open this repo in Claude Code and run `/portfolio`.
   You should see your paper account and (empty) positions print cleanly.
4. Try `/pre-market` to generate a research log entry.
5. When ready to automate, create a private GitHub repo, push this, install the
   Claude GitHub App on it, and set up the five cloud routines — see
   [routines/README.md](routines/README.md).

## Two execution modes

- **Local mode:** run `/portfolio`, `/pre-market`, etc. manually in Claude Code.
  Credentials come from local `.env`. Good for testing.
- **Cloud mode:** the five `routines/*.md` fire on cron. Credentials come from
  the routine's environment variables. **No `.env` file in the cloud.** This is
  the production path.

## Safety

- `.env` is gitignored. Never commit real credentials.
- Never share API keys, positions, or P&L externally.
- Every trade is documented in `memory/RESEARCH-LOG.md` *before* execution.
