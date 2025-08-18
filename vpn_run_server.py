import mysql.connector
import pandas as pd
import os
import json 
import gspread
from google.oauth2.service_account import Credentials



conn = mysql.connector.connect(
    host='10.0.0.1',   # VPN IP
    port=3306,
    user='sazid',
    password='123456789abc',
    database='erpboss'
)

df = pd.read_sql("SELECT * FROM stock LIMIT 50;", conn)
print(df)

conn.close()


# Authenticate
scopes = ["https://www.googleapis.com/auth/spreadsheets",
          "https://www.googleapis.com/auth/drive"]



creds_json = os.getenv("SERVICE_ACNT_CRED")
creds_dict = json.loads(creds_json)

creds = Credentials.from_service_account_info(
    creds_dict,  scopes=scopes
)

client = gspread.authorize(creds)
sheet = client.open("test_auto").sheet1

# Convert DataFrame to list of lists
rows_to_append = df.values.tolist()

# Append all rows at once
sheet.append_rows(rows_to_append, value_input_option='USER_ENTERED')
print("Data appended successfully!")
