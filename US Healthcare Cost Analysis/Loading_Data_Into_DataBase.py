import pandas as pd
from sqlalchemy import create_engine

# Connect to SQL Server
engine = create_engine(
    r'mssql+pyodbc://YOUR SERVER NAME/Healthcare_Cost_DB'
    '?driver=ODBC+Driver+17+for+SQL+Server'
    '&trusted_connection=yes'
)

# ── Table 1: hospital_charges ──────────────────────────────
df_hospital = pd.read_csv(
    r'D:\Full Projects\project 12\MUP_INP_RY26_P03_V10_DY24_PrvSvc.CSV',
    dtype=str,
    encoding='utf-8'
)

df_hospital.to_sql(
    'hospital_charges',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"hospital_charges done — {len(df_hospital)} rows loaded.")

# ── Table 2: household_income ──────────────────────────────
df_income = pd.read_csv(
    r'D:\Full Projects\project 12\Official_US_Median_Household_Income_2024.csv',
    dtype=str,
    encoding='utf-8'
)

df_income.to_sql(
    'household_income',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"household_income done — {len(df_income)} rows loaded.")
