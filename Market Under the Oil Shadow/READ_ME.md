# Market Under the Oil Shadow

## Project Overview

**Market Under the Oil Shadow** is a data analytics project that studies how oil price movements ripple through global equity markets. The pipeline covers **30 tickers across 7 sectors** over a 3-year daily period, sourced from Yahoo Finance via `yfinance` — with a focus on the Hormuz Strait crisis period.

---

## Sectors & Tickers

| Sector | Tickers |
|---|---|
| Oil & Energy | `CL=F` `BZ=F` `XOM` `CVX` `SLB` `XLE` |
| Technology | `AAPL` `MSFT` `NVDA` `GOOGL` `XLK` |
| Finance | `JPM` `BAC` `GS` `XLF` |
| Healthcare | `JNJ` `PFE` `UNH` `XLV` |
| Consumer | `AMZN` `WMT` `MCD` `XLY` |
| Gulf Market | `2222.SR` `2010.SR` `1180.SR` |
| Benchmarks | `^GSPC` `^IXIC` `GC=F` `^VIX` |

---

## Dataset at a Glance

| | |
|---|---|
| Total tickers | 30 |
| Sectors | 7 |
| Price history rows | 22,521 |
| Period | 3 years daily (2023 – 2026) |
| Interval | 1 day · auto-adjusted prices |
| Source | Yahoo Finance via `yfinance` |

**Yahoo Finance** → **Python** (Jupyter) → **SQL Server** → **Power BI**
