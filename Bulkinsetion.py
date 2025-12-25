import pandas as pd
import mysql.connector

# Read the CSV file into a DataFrame
df = pd.read_csv('product.csv')

# Connect to MySQL
connection = mysql.connector.connect(
     host="127.0.0.1",
    user="root",
    password="Ndc1181s",
    database="trig"
)

cursor = connection.cursor()

# Insert data row by row
for i, row in df.iterrows():
    cursor.execute(
        "INSERT INTO Product (ProductName, CategoryID, Price, StockQuantity) VALUES (%s, %s, %s, %s)",
        (row['ProductName'], row['CategoryID'], row['Price'], row['StockQuantity'])
    )

# Commit and close connection
connection.commit()
cursor.close()
connection.close()


print("Bulk insert completed successfully!")
