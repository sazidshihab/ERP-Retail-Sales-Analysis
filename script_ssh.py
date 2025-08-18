import pandas as pd
import mysql.connector
import os
import json
import gspread
from google.oauth2.service_account import Credentials
from sshtunnel import SSHTunnelForwarder

# Read DB & SSH credentials from environment variables
SSH_HOST = os.getenv("DB_HOST")         # EC2 public IP or hostname
SSH_USER = os.getenv("DB_USER")         # EC2 SSH user, e.g., 'ubuntu'
SSH_KEY = os.path.expanduser("~/.ssh/id_rsa")  # GitHub Actions private key stored in ~/.ssh

DB_HOST = '127.0.0.1'                   # MySQL will be accessed through local tunnel
DB_PORT = int(os.getenv("DB_PORT", 3306))
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")

# Start SSH tunnel
with SSHTunnelForwarder(
    (SSH_HOST, 22),
    ssh_username=SSH_USER,
    ssh_pkey=SSH_KEY,
    remote_bind_address=(DB_HOST, DB_PORT)
) as tunnel:

    # Connect to MySQL through the tunnel
    conn = mysql.connector.connect(
        host='127.0.0.1',
        port=tunnel.local_bind_port,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME
    )

    # Example query
    query = "SELECT * FROM stock LIMIT 10;"
    df = pd.read_sql(query, conn)
    print(df.head())

    conn.close()

# Google Sheets authentication
scopes = [
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/drive"
]

creds_json = os.getenv("SERVICE_ACNT_CRED")
creds_dict = json.loads(creds_json)
creds = Credentials.from_service_account_info(creds_dict, scopes=scopes)

client = gspread.authorize(creds)
sheet = client.open("test_auto").sheet1

# Convert DataFrame to list of lists and append to sheet
rows_to_append = df.values.tolist()
sheet.append_rows(rows_to_append, value_input_option='USER_ENTERED')
print("Data appended successfully!")
