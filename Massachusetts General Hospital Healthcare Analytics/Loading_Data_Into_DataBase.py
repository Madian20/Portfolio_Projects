import pandas as pd
from sqlalchemy import create_engine


engine = create_engine(
    r'mssql+pyodbc://YOUR SERVER NAME/Healthcare_DB'
    '?driver=ODBC+Driver+17+for+SQL+Server'
    '&trusted_connection=yes'
)

# ── Table 1: encounters ────────────────────────────────────
df_encounters = pd.read_csv(
    r'D:\Full Projects\project 13\Hospital+Patient+Records\encounters.csv',
    dtype=str,
    encoding='utf-8'
)

df_encounters.to_sql(
    'encounters',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"encounters done — {len(df_encounters)} rows loaded.")

# ── Table 2: organizations ─────────────────────────────────
df_organizations = pd.read_csv(
    r'D:\Full Projects\project 13\Hospital+Patient+Records\organizations.csv',
    dtype=str,
    encoding='utf-8'
)

df_organizations.to_sql(
    'organizations',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"organizations done — {len(df_organizations)} rows loaded.")

# ── Table 3: patients ──────────────────────────────────────
df_patients = pd.read_csv(
    r'D:\Full Projects\project 13\Hospital+Patient+Records\patients.csv',
    dtype=str,
    encoding='utf-8'
)

df_patients.to_sql(
    'patients',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"patients done — {len(df_patients)} rows loaded.")

# ── Table 4: payers ────────────────────────────────────────
df_payers = pd.read_csv(
    r'D:\Full Projects\project 13\Hospital+Patient+Records\payers.csv',
    dtype=str,
    encoding='utf-8'
)

df_payers.to_sql(
    'payers',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"payers done — {len(df_payers)} rows loaded.")

# ── Table 5: procedures ────────────────────────────────────
df_procedures = pd.read_csv(
    r'D:\Full Projects\project 13\Hospital+Patient+Records\procedures.csv',
    dtype=str,
    encoding='utf-8'
)

df_procedures.to_sql(
    'procedures',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"procedures done — {len(df_procedures)} rows loaded.")
