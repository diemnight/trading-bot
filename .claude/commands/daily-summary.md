---
description: Daily summary workflow (local). Writes EOD snapshot + sends recap.
---

Local daily summary. Credentials from local .env. No git push.
Resolve DATE=$(date +%Y-%m-%d).

STEP 1 — Read tail of TRADE-LOG.md (most recent EOD snapshot -> yesterday's
  equity), count today's trades, count this week's trades.

STEP 2 — Pull final state: account, positions, orders, python3 scripts/ta.py each open ticker.

STEP 3 — Compute: Day P&L ($ and %), phase cumulative P&L, trades today,
  trades this week.

STEP 4 — Append EOD snapshot to memory/TRADE-LOG.md:
  ### MMM DD — EOD Snapshot (Day N, Weekday)
  **Portfolio:** $X | **Cash:** $X (X%) | **Day P&L:** ±$X (±X%) | **Phase P&L:** ±$X (±X%)
  | Ticker | Shares | Entry | Close | Day Chg | Unrealized P&L | Stop |
  **Notes:** one-paragraph plain-english summary.

STEP 5 — Send ONE recap (always, even no-trade days), <= 15 lines. Include each
  open position with a compact technical tag from ta.py (trend + RSI + stop):
  bash scripts/notify.sh "EOD MMM DD ...
    SYM ±X.X% | trend UP/DOWN | RSI NN | stop \$X.XX ..."
