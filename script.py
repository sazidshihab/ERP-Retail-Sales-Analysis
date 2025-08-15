
import pymysql
import pandas as pd

conn = pymysql.connect(
    host='13.60.117.189',  # public IP of your EC2
    port=33306,            # remote port forwarded to your Mac
    user='MYSQL_USER',     # MySQL user on your Mac
    password='MYSQL_PASSWORD',
    database='erpboss'
)

df = pd.read_sql("SELECT * FROM stock", conn)
print(df.head())
conn.close()
