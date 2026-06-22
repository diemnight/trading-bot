---
description: Market-open execution workflow (local). Places planned trades + stops.
---

Local market-open execution. Credentials from local .env. No git push.
Resolve DATE=$(date +%Y-%m-%d).

STEP 1 — Read TRADING-STRATEGY.md, today's RESEARCH-LOG.md entry (if missing,
  run pre-market steps inline), tail TRADE-LOG.md for weekly trade count.

STEP 2 — Re-validate: account, positions, quote each planned ticker,
  python3 scripts/ta.py each planned ticker (EMA/RSI/volume/support-resistance).

STEP 3 — Hard-check rules BEFORE every order, skip + log any that fail:
  positions after trade <= 6, trades this week <= 3, cost <= 20% equity,
  cost <= cash, catalyst documented, daytrade_count leaves PDT room.
  TECHNICAL (from ta.py): REQUIRED trend not DOWN (price >= 50 EMA);
  confirm+log volume >= 1.2x and RSI < 75; need >= 2:1 R:R to resistance.

STEP 4 — Execute buys (market, day TIF):
  bash scripts/alpaca.sh order '{"symbol":"SYM","qty":"N","side":"buy","type":"market","time_in_force":"day"}'
  Wait for fill before placing the stop.

STEP 5 — Immediately place a protective GTC stop per new position. If nearest
  support (from ta.py) sits 7-10% below entry, use a FIXED stop just below it;
  else default 10% trailing. Never within 3% of price; never move a stop down.
  bash scripts/alpaca.sh order '{"symbol":"SYM","qty":"N","side":"sell","type":"trailing_stop","trail_percent":"10","time_in_force":"gtc"}'
  On PDT rejection: fixed stop 10% below entry. If blocked, queue in TRADE-LOG.

STEP 6 — Append each trade to memory/TRADE-LOG.md (date, ticker, side, shares,
  entry, stop, thesis, target, R:R).

STEP 7 — bash scripts/notify.sh on any decision (trade OR deliberate HOLD). Include
  the "📚 Why this decision" mentor block: why chosen/why waiting, why not the
  obvious alternative, and the entry/technical justification (see CLAUDE.md).
