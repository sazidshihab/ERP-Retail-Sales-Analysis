import pymysql
import pandas as pd

conn = pymysql.connect(
    host='10.0.0.1',   # VPN IP
    port=3306,
    user='sazid',
    password='123456789abc',
    database='erpboss'
)

df = pd.read_sql("SELECT * FROM stock LIMIT 10;", conn)
print(df)

conn.close()
