#!/usr/bin/env python3
"""Technical-analysis snapshot for one ticker.

Usage: python3 scripts/ta.py SYM
Fetches daily bars via scripts/alpaca.sh and prints a compact, deterministic
indicator block the trading bot can reason about. The LLM must NOT compute
these numbers itself — this script is the source of truth.

Indicators:
  - EMA20, EMA50 (trend)
  - RSI14 (Wilder's smoothing)
  - current volume vs 20-day average volume (confirmation)
  - support / resistance from recent 20-bar swing low / high

Degrades gracefully: on any data problem it prints a NOTE line and exits 0 so
the caller can proceed without TA (like the perplexity.sh fallback).
"""
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def fetch_bars(sym: str):
    out = subprocess.run(
        ["bash", str(ROOT / "scripts" / "alpaca.sh"), "bars", sym, "120"],
        capture_output=True, text=True,
    )
    if out.returncode != 0:
        raise RuntimeError(out.stderr.strip() or "alpaca.sh bars failed")
    data = json.loads(out.stdout)
    bars = data.get("bars") or []
    if not bars:
        raise RuntimeError("no bars returned (data feed/subscription?)")
    return bars


def ema(values, period):
    if len(values) < period:
        return None
    k = 2 / (period + 1)
    e = sum(values[:period]) / period  # seed with SMA
    for v in values[period:]:
        e = v * k + e * (1 - k)
    return e


def rsi(closes, period=14):
    if len(closes) < period + 1:
        return None
    deltas = [closes[i] - closes[i - 1] for i in range(1, len(closes))]
    gains = [max(d, 0) for d in deltas]
    losses = [max(-d, 0) for d in deltas]
    avg_gain = sum(gains[:period]) / period
    avg_loss = sum(losses[:period]) / period
    for i in range(period, len(deltas)):
        avg_gain = (avg_gain * (period - 1) + gains[i]) / period
        avg_loss = (avg_loss * (period - 1) + losses[i]) / period
    if avg_loss == 0:
        return 100.0
    rs = avg_gain / avg_loss
    return 100 - 100 / (1 + rs)


def main():
    if len(sys.argv) < 2:
        print("usage: python3 scripts/ta.py SYM", file=sys.stderr)
        sys.exit(1)
    sym = sys.argv[1].upper()

    try:
        bars = fetch_bars(sym)
    except Exception as e:  # noqa: BLE001 - degrade gracefully
        print(f"{sym}  TA NOTE: indicators unavailable ({e}) — proceed without TA")
        sys.exit(0)

    closes = [b["c"] for b in bars]
    highs = [b["h"] for b in bars]
    lows = [b["l"] for b in bars]
    vols = [b["v"] for b in bars]
    price = closes[-1]

    e20 = ema(closes, 20)
    e50 = ema(closes, 50)
    r = rsi(closes, 14)

    recent_vol = vols[-1]
    avg_vol = sum(vols[-20:]) / min(len(vols), 20)
    vol_x = recent_vol / avg_vol if avg_vol else 0

    win = min(len(bars), 20)
    support = min(lows[-win:])
    resistance = max(highs[-win:])

    # Trend classification
    if e20 and e50:
        if price > e50 and e20 > e50:
            trend = "UP"
        elif price < e50 and e20 < e50:
            trend = "DOWN"
        else:
            trend = "MIXED"
    else:
        trend = "n/a (insufficient history)"

    def pos(x):
        return "above" if x and price > x else "below"

    def pct(a, b):
        return (a - b) / b * 100 if b else 0

    rsi_tag = "n/a"
    if r is not None:
        rsi_tag = ("overbought" if r >= 75 else
                   "high" if r >= 70 else
                   "oversold" if r <= 30 else "neutral")
    vol_tag = "confirmed" if vol_x >= 1.2 else "light" if vol_x < 0.8 else "normal"

    e20s = f"{e20:.2f} ({pos(e20)})" if e20 else "n/a"
    e50s = f"{e50:.2f} ({pos(e50)})" if e50 else "n/a"
    rs = f"{r:.0f} ({rsi_tag})" if r is not None else "n/a"

    print(
        f"{sym}  price {price:.2f} | EMA20 {e20s} | EMA50 {e50s} | trend {trend}\n"
        f"      RSI14 {rs} | vol {vol_x:.1f}x 20d-avg ({vol_tag})\n"
        f"      support {support:.2f} ({pct(price, support):+.1f}%) | "
        f"resistance {resistance:.2f} ({pct(resistance, price):+.1f}% to go)"
    )


if __name__ == "__main__":
    main()
