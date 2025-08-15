import pymysql
import pandas as pd

# EC2 reverse tunnel points to your Mac MySQL
conn = pymysql.connect(
    host='13.60.117.189',  # EC2 public IP
    port=33306,            # Reverse tunnel port
    user='sazid',
    password='123456789abc',
    database='erpboss'
)






df = pd.read_sql("SELECT * FROM stock", conn)
print(df.head())  # Output will appear in GitHub Actions log

conn.close()
