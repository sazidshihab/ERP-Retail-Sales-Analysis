
import pymysql
import pandas as pd

conn = pymysql.connect(
    host="localhost",  # Or localhost if running locally
    user="sazid",
    password="123456789abc",
    database="erpboss"
)

df = pd.read_sql("SELECT * FROM stock", conn)
print(df.head())
conn.close()
