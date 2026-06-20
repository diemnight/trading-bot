---
description: Weekly review workflow (local). Friday recap with letter grade.
---

Local Friday weekly review. Credentials from local .env. No git push.
Resolve DATE=$(date +%Y-%m-%d).

STEP 1 — Read WEEKLY-REVIEW.md (match template), all this week's TRADE-LOG.md
  and RESEARCH-LOG.md entries, TRADING-STRATEGY.md.

STEP 2 — Pull week-end state: account, positions.

STEP 3 — Compute: starting portfolio (Mon AM), ending portfolio, week return
  ($ and %), S&P 500 week return (bash scripts/perplexity.sh "S&P 500 weekly
  performance week ending $DATE", fall back to WebSearch on exit 3), trades
  W/L/open, win rate, best/worst trade, profit factor.

STEP 4 — Append full review to memory/WEEKLY-REVIEW.md: stats table, closed
  trades table, open positions, what worked / didn't (3-5 each), key lessons,
  adjustments for next week, overall grade A-F.

STEP 5 — If a rule proved out 2+ weeks or failed badly, update
  memory/TRADING-STRATEGY.md and call out the change.

STEP 6 — Send ONE recap with headline numbers via bash scripts/notify.sh.
