---
description: Pre-market research workflow (local). Writes today's RESEARCH-LOG entry.
---

Local pre-market research. Credentials come from local .env. No git push
(you commit manually when testing). Resolve DATE=$(date +%Y-%m-%d).

STEP 1 — Read memory: TRADING-STRATEGY.md, tail TRADE-LOG.md, tail RESEARCH-LOG.md.

STEP 2 — Pull live state:
  bash scripts/alpaca.sh account
  bash scripts/alpaca.sh positions
  bash scripts/alpaca.sh orders

STEP 3 — Research via bash scripts/perplexity.sh "<query>" for:
  oil prices, S&P 500 futures, VIX, top catalysts $DATE, earnings before open,
  economic calendar, sector momentum, news on each held ticker.
  If perplexity.sh exits 3, fall back to native WebSearch and note it.

STEP 4 — Write a dated entry to memory/RESEARCH-LOG.md:
  account snapshot, market context, 2-3 trade ideas (catalyst/entry/stop/target),
  risk factors, decision (default HOLD).

STEP 5 — Optional: bash scripts/notify.sh "<one line>" only if urgent.
