# Trading Strategy

## Mission
Beat the S&P 500 over the challenge window. Stocks only — no options, ever.
This is a PAPER account (~$100,000 simulated).

## Capital & Constraints
- Starting capital: ~$100,000 (paper)
- Platform: Alpaca (paper-api.alpaca.markets)
- Instruments: Stocks ONLY
- PDT limit: 3 day trades per 5 rolling days (account < $25k)

## Core Rules
1. NO OPTIONS — ever
2. 75-85% deployed
3. 5-6 positions at a time, max 20% each
4. 10% trailing stop on every position as a real GTC order
5. Cut losers at -7% manually
6. Tighten trail: 7% at +15%, 5% at +20%
7. Never within 3% of current price; never move a stop down
8. Max 3 new trades per week
9. Follow sector momentum
10. Exit a sector after 2 consecutive failed trades
11. Patience > activity

## Deployment Pace (added 2026-07-03, after 2 weeks under-deployed)
Rule 2 (75-85% deployed) is a target we kept missing — ended wk1 ~17% and wk2 ~31%.
In wk2 that cost us: the S&P rose ~+1.8% while we sat 69% cash and finished red.
Cash above the target is an implicit market-direction bet, not a neutral default.
Guardrails to force the fix WITHOUT abandoning patience:
- Deployment floor ratchet: reach >=50% deployed by the end of any phase's first
  full week; do not sit below 50% for more than 2 consecutive sessions without a
  specific, logged tape reason (e.g., a known binary event ahead).
- Never let a single setup be the ONLY deployment path — keep a ranked watchlist of
  3-4 confirmed leaders so one stalled chart can't freeze the book.
- This does NOT override the entry checklist or the trend gate: every add must still
  confirm (catalyst + above 50 EMA on volume). Pace the deployment; never force a
  bad entry to hit a number.

## Entry Checklist
- Specific catalyst?
- Sector in momentum?
- Stop level (7-10% below entry)
- Target (min 2:1 R:R)

## Technical Filters (catalyst leads; TA refines timing + stops)
Run `python3 scripts/ta.py SYM` for deterministic EMA20/50, RSI14, relative
volume, and support/resistance. Never eyeball these — the script is the source
of truth. If it prints "TA NOTE: indicators unavailable", proceed without TA.

- TREND (near-hard gate): do NOT buy when trend is DOWN (price below 50 EMA).
  Prefer trend UP (price > 50 EMA and 20 > 50). Reinforces sector-momentum rule.
- VOLUME (soft confirm, logged): prefer the catalyst move on >= 1.2x 20d-avg
  volume. Light volume = weaker conviction; note it, don't veto.
- RSI14 (soft flag, never a veto): RSI >= 75 = overbought — prefer a pullback or
  half size. In strong momentum RSI can stay high; do not skip leaders on RSI alone.
- SUPPORT/RESISTANCE (stops + targets): place the protective stop just below
  nearest support when that sits 7-10% below entry (structure-based, tighter R:R);
  else default to the 10% trailing stop. Use resistance as the near-term target and
  for the >= 2:1 R:R check. Skip if price is jammed < 2% under resistance.
- Still obey core stop rules: never within 3% of price, never move a stop down.
