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
query = "SELECT * FROM your_table LIMIT 10;"

# Load data into pandas
df = pd.read_sql(query, conn)
print(df.head())

conn.close()
