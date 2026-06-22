#!/usr/bin/env bash
# Alpaca API wrapper. All trading API calls go through here.
# Usage: bash scripts/alpaca.sh <subcommand> [args...]
#
# Subcommands:
#   account                 # equity, cash, buying_power, daytrade_count
#   positions               # all open positions w/ unrealized P&L
#   position SYM            # single position
#   quote SYM               # latest bid/ask (uses data.alpaca.markets)
#   orders [status]         # default status=open
#   order '<json>'          # POST a new order
#   cancel ORDER_ID         # cancel one order
#   cancel-all              # cancel all open orders
#   close SYM               # market-sell entire position
#   close-all               # close everything

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

: "${ALPACA_API_KEY:?ALPACA_API_KEY not set in environment}"
: "${ALPACA_SECRET_KEY:?ALPACA_SECRET_KEY not set in environment}"

# Defaults to PAPER trading. Override ALPACA_ENDPOINT for live.
API="${ALPACA_ENDPOINT:-https://paper-api.alpaca.markets/v2}"
DATA="${ALPACA_DATA_ENDPOINT:-https://data.alpaca.markets/v2}"

H_KEY="APCA-API-KEY-ID: $ALPACA_API_KEY"
H_SEC="APCA-API-SECRET-KEY: $ALPACA_SECRET_KEY"

cmd="${1:-}"
shift || true

case "$cmd" in
  account)
    curl -fsS -H "$H_KEY" -H "$H_SEC" "$API/account"
    ;;
  positions)
    curl -fsS -H "$H_KEY" -H "$H_SEC" "$API/positions"
    ;;
  position)
    sym="${1:?usage: position SYM}"
    curl -fsS -H "$H_KEY" -H "$H_SEC" "$API/positions/$sym"
    ;;
  quote)
    sym="${1:?usage: quote SYM}"
    curl -fsS -H "$H_KEY" -H "$H_SEC" "$DATA/stocks/$sym/quotes/latest"
    ;;
  bars)
    sym="${1:?usage: bars SYM [limit] [timeframe]}"
    limit="${2:-120}"
    tf="${3:-1Day}"
    feed="${ALPACA_DATA_FEED:-iex}"
    # Alpaca needs an explicit start, else it anchors to "now" and returns null.
    # Look back ~250 calendar days to guarantee >50 trading bars for EMA50.
    start="$(date -u -d '250 days ago' +%Y-%m-%d 2>/dev/null || python3 -c 'import datetime;print((datetime.date.today()-datetime.timedelta(days=250)).isoformat())')"
    # sort=desc so 'limit' counts back from today -> the most RECENT bars
    curl -fsS -H "$H_KEY" -H "$H_SEC" \
      "$DATA/stocks/$sym/bars?timeframe=$tf&limit=$limit&adjustment=raw&feed=$feed&start=$start&sort=desc"
    ;;
  orders)
    status="${1:-open}"
    curl -fsS -H "$H_KEY" -H "$H_SEC" "$API/orders?status=$status"
    ;;
  order)
    body="${1:?usage: order '<json>'}"
    curl -fsS -H "$H_KEY" -H "$H_SEC" -H "Content-Type: application/json" \
      -X POST -d "$body" "$API/orders"
    ;;
  cancel)
    oid="${1:?usage: cancel ORDER_ID}"
    curl -fsS -H "$H_KEY" -H "$H_SEC" -X DELETE "$API/orders/$oid"
    ;;
  cancel-all)
    curl -fsS -H "$H_KEY" -H "$H_SEC" -X DELETE "$API/orders"
    ;;
  close)
    sym="${1:?usage: close SYM}"
    curl -fsS -H "$H_KEY" -H "$H_SEC" -X DELETE "$API/positions/$sym"
    ;;
  close-all)
    curl -fsS -H "$H_KEY" -H "$H_SEC" -X DELETE "$API/positions"
    ;;
  *)
    echo "Usage: bash scripts/alpaca.sh <account|positions|position|quote|bars|orders|order|cancel|cancel-all|close|close-all> [args]" >&2
    exit 1
    ;;
esac
echo
