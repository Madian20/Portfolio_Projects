import pandas as pd
from sqlalchemy import create_engine


engine = create_engine(
    r'mssql+pyodbc://DESKTOP-931U322\SQLEXPRESS/Olist_DB'
    '?driver=ODBC+Driver+17+for+SQL+Server'
    '&trusted_connection=yes'
)

# ── Table 1: orders ────────────────────────────────────────
df_orders = pd.read_csv(
    r'D:\Full Projects\project4\2\olist_orders_dataset.csv',
    dtype=str,
    encoding='utf-8'
)

df_orders.to_sql(
    'orders',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"orders done — {len(df_orders)} rows loaded.")

# ── Table 2: order_items ───────────────────────────────────
df_order_items = pd.read_csv(
    r'D:\Full Projects\project4\2\olist_order_items_dataset.csv',
    dtype=str,
    encoding='utf-8'
)

df_order_items.to_sql(
    'order_items',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"order_items done — {len(df_order_items)} rows loaded.")

# ── Table 3: order_payments ────────────────────────────────
df_order_payments = pd.read_csv(
    r'D:\Full Projects\project4\2\olist_order_payments_dataset.csv',
    dtype=str,
    encoding='utf-8'
)

df_order_payments.to_sql(
    'order_payments',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"order_payments done — {len(df_order_payments)} rows loaded.")

# ── Table 4: order_reviews ─────────────────────────────────
df_order_reviews = pd.read_csv(
    r'D:\Full Projects\project4\2\olist_order_reviews_dataset.csv',
    dtype=str,
    encoding='utf-8'
)

df_order_reviews.to_sql(
    'order_reviews',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"order_reviews done — {len(df_order_reviews)} rows loaded.")

# ── Table 5: customers ─────────────────────────────────────
df_customers = pd.read_csv(
    r'D:\Full Projects\project4\2\olist_customers_dataset.csv',
    dtype=str,
    encoding='utf-8'
)

df_customers.to_sql(
    'customers',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"customers done — {len(df_customers)} rows loaded.")

# ── Table 6: sellers ───────────────────────────────────────
df_sellers = pd.read_csv(
    r'D:\Full Projects\project4\2\olist_sellers_dataset.csv',
    dtype=str,
    encoding='utf-8'
)

df_sellers.to_sql(
    'sellers',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"sellers done — {len(df_sellers)} rows loaded.")

# ── Table 7: products ──────────────────────────────────────
df_products = pd.read_csv(
    r'D:\Full Projects\project4\2\olist_products_dataset.csv',
    dtype=str,
    encoding='utf-8'
)

df_products.to_sql(
    'products',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"products done — {len(df_products)} rows loaded.")

# ── Table 8: category_translation ─────────────────────────
df_category = pd.read_csv(
    r'D:\Full Projects\project4\2\product_category_name_translation.csv',
    dtype=str,
    encoding='utf-8'
)

df_category.to_sql(
    'category_translation',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"category_translation done — {len(df_category)} rows loaded.")

# ── Table 9: geolocation ───────────────────────────────────
df_geolocation = pd.read_csv(
    r'D:\Full Projects\project4\2\olist_geolocation_dataset.csv',
    dtype=str,
    encoding='utf-8'
)

df_geolocation.to_sql(
    'geolocation',
    con=engine,
    if_exists='append',
    index=False,
    chunksize=1000
)

print(f"geolocation done — {len(df_geolocation)} rows loaded.")
