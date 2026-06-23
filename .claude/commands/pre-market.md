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

STEP 3b — python3 scripts/ta.py each candidate ticker (EMA/RSI/volume/S-R).

STEP 4 — Write a dated entry to memory/RESEARCH-LOG.md:
  account snapshot, market context, 2-3 trade ideas (catalyst/entry/stop/target
  + one-line technical read from ta.py; prefer uptrends, flag overbought/at-resistance),
  risk factors, thesis depth (why this theme vs the obvious alternative + one
  teachable concept, for the educational alerts), decision (default HOLD).

STEP 5 — ALWAYS send a morning-briefing notification (short headline + "— details —"
  long block): market read, plan (trade/HOLD), the 2-3 ideas with entry/stop/target,
  what was avoided + why, risks, and a "📚 Why this thinking" teachable concept.
  bash scripts/notify.sh "🌅 Pre-market MMM DD — <verdict> ...\n\n— details —\n..."
