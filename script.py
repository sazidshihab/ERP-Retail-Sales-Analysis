import pandas as pd
import mysql.connector
import os

# Read DB credentials from environment variables
DB_HOST = os.getenv("DB_HOST")
DB_PORT = int(os.getenv("DB_PORT", 3306))
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")

# Connect to MySQL
conn = mysql.connector.connect(
    host=DB_HOST,
    port=DB_PORT,
    user=DB_USER,
    password=DB_PASSWORD,
    database=DB_NAME
)

# Example query
query = "SELECT * FROM stock LIMIT 10;"

# Load data into pandas
df = pd.read_sql(query, conn)
print(df.head())

conn.close()


import gspread
from google.oauth2.service_account import Credentials
import pandas as pd


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


