import mysql.connector
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os

# Function to send email
def send_email(subject, body):
    sender_email = "nabiurrahman2004@gmail.com"
    to_email = "nabiurraouf2004@gmail.com"
    sender_password = "rxbi vnae fdak cznr"
    smtp_server = "smtp.gmail.com"
    smtp_port = 587

    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = to_email
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    with smtplib.SMTP(smtp_server, smtp_port) as server:
        server.starttls()
        server.login(sender_email, sender_password)
        text = msg.as_string()
        server.sendmail(sender_email, to_email, text)

# Connect to MySQL
def check_alerts():
    connection = mysql.connector.connect(
        host="127.0.0.1",
        user="root",
        password="Ndc1181s",
        database="trig"
    )

    cursor = connection.cursor(dictionary=True)

    # Query to fetch the latest alerts
    cursor.execute("SELECT * FROM Alert WHERE time > NOW() - INTERVAL 5 minute")
    alerts = cursor.fetchall()

    # If there are any new alerts, send an email
    for alert in alerts:
        product_id = alert['PRODUCT_ID']
        reason = alert['REASON']
        changes = alert['CHANGES']
        subject = f"Alert: Product {product_id} - {reason}"
        body = f"Alert Reason: {reason}\nChanges: {changes}"

        # Send email to your boss
        send_email(subject, body)

    cursor.close()
    connection.close()
# Check for alerts every 5 minutes
import time
while True:
    check_alerts()
    time.sleep(300)  # Sleep for 5 minutes
