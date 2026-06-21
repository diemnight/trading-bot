---
description: Midday scan workflow (local). Cuts losers, tightens stops on winners.
---

Local midday scan. Credentials from local .env. No git push.
Resolve DATE=$(date +%Y-%m-%d).

STEP 1 — Read TRADING-STRATEGY.md (exit rules), tail TRADE-LOG.md (entries,
  thesis per position, stops), today's RESEARCH-LOG.md.

STEP 2 — Pull state: positions, orders, python3 scripts/ta.py each open ticker.

STEP 3 — Cut losers. For every position where unrealized_plpc <= -0.07:
  bash scripts/alpaca.sh close SYM
  bash scripts/alpaca.sh cancel ORDER_ID   # its trailing stop
  Log exit to TRADE-LOG (exit price, realized P&L, "cut at -7% per rule").

STEP 4 — Tighten winners. Cancel old trailing stop, place new:
  up >= +20% -> trail_percent "5";  up >= +15% -> trail_percent "7".
  Never tighten within 3% of price. Never move a stop down.

STEP 5 — Thesis + technical check: cut even if not at -7% if the thesis broke
  OR ta.py shows a breakdown (lost 50 EMA on volume, broke support, bearish RSI
  divergence). TA is confirmation, not a hair-trigger. Document in TRADE-LOG.

STEP 6 — Optional intraday Perplexity research if something moves sharply
  with no obvious cause; append addendum to RESEARCH-LOG.

STEP 7 — bash scripts/notify.sh only if action was taken.
