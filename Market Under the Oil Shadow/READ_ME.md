# Market Under the Oil Shadow

## Project Overview

**Market Under the Oil Shadow** is a data analytics project that studies how oil price movements ripple through global equity markets. The pipeline covers **30 tickers across 7 sectors** over a 3-year daily period, sourced from Yahoo Finance via `yfinance` — with a focus on the Hormuz Strait crisis period.

---

## Motivation

Oil doesn't move quietly. When prices spike or collapse, the effects don't stay in the energy sector — they spread. The question is: how far, how fast, and who feels it most?

This project started from that question, and a simple premise: **if you can measure the relationship between oil and equities across sectors and time, you can start to understand market behavior at a deeper level.**

---

## Goal

> Build a fully end-to-end data analytics project — from raw API data to SQL to Power BI — that is **practical, reproducible, and beginner-friendly**; while answering a real market question: which sectors move with oil, which resist it, and which flip their relationship during periods of geopolitical stress.

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

---

## Project Phases

**Phase 1 — Data Pipeline (Python)**
Pull 3 years of daily OHLCV data for 30 tickers via `yfinance`, calculate derived metrics, fetch company metadata, build oil correlation table, and export 5 clean CSVs.

**Cleaning applied:**
- Prices auto-adjusted for splits and dividends via `auto_adjust=True`
- All floats rounded to 4 decimal places for clean CSV output
- Multi-level column index flattened where yfinance returns tuples

**Calculated columns:**

| Column | Description |
|---|---|
| `Daily_Return_%` | Day-over-day price change % |
| `Intraday_Range` | High minus Low |
| `Intraday_Range_%` | Intraday range as % of Close |
| `Volatility_30D` | Rolling 30-day std dev of daily returns |
| `Avg_Volume_30D` | Rolling 30-day average volume |
| `MA_30D` / `MA_90D` | 30 and 90-day moving averages |
| `Cumulative_Return_%` | Total return from start of period |
| `Pct_Above_MA30` | % distance from current price to MA30 |
| `Prev_Close` | Previous day closing price |
| `Price_Change` | Close minus Prev_Close |
| `Volume_Spike` | Flag: 1 if volume > 2× 30-day average |
| `Analyst_Upside_%` | `(Target Price − Current Price) / Current Price × 100` |

---

**Phase 2 — Data Warehouse (SQL Server)**
Load all CSVs into SQL Server, cast columns to proper data types, define primary and foreign keys, and run exploratory queries to validate the data and surface early insights.

---

**Phase 3 — Dashboard (Power BI)**
Connect SQL Server to Power BI, build the data model, write DAX measures, and deliver a 4-page report covering price behavior, sector comparison, oil correlation, and company fundamentals.

---

## Code Highlights

### Cleaning

Auto-adjusting prices and flattening the column index:

```python
df = yf.download(
    ticker,
    period=PERIOD,
    interval=INTERVAL,
    auto_adjust=True,
    progress=False
)

# Flatten multi-level column index
df.columns = [c[0] if isinstance(c, tuple) else c for c in df.columns]

# Round all floats to 4 decimal places
float_cols = combined.select_dtypes(include="float64").columns
combined[float_cols] = combined[float_cols].round(4)
```

---

### Calculated Columns

```python
df["Daily_Return_%"]      = df["Close"].pct_change() * 100
df["Intraday_Range"]      = df["High"] - df["Low"]
df["Volatility_30D"]      = df["Daily_Return_%"].rolling(30).std()
df["MA_30D"]              = df["Close"].rolling(30).mean()
df["Cumulative_Return_%"] = ((df["Close"] - df["Close"].iloc[0]) / df["Close"].iloc[0]) * 100
df["Volume_Spike"]        = (df["Volume"] > df["Avg_Volume_30D"] * 2).astype(int)

# Analyst upside in company_info
df["Analyst_Upside_%"] = (
    (df["targetMeanPrice"] - df["currentPrice"]) / df["currentPrice"] * 100
).round(2)
```


