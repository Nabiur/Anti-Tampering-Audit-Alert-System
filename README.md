# Anti-Tampering Audit Alert System

![SQL](https://img.shields.io/badge/SQL-MySQL-4479A1?logo=mysql&logoColor=white) ![Python](https://img.shields.io/badge/Python-3.x-3776AB?logo=python&logoColor=white) ![Focus](https://img.shields.io/badge/Focus-Audit%20Triggers-1F6FEB)

## Overview
This project demonstrates a database-first monitoring workflow for product data integrity. It uses MySQL triggers to detect risky product changes (large price or stock jumps), stores audit history, and supports email-based alerting.

## What this project does
- Tracks inserts, updates, and deletes on the `Product` table.
- Logs all changes in a `History` table with JSON snapshots.
- Raises alerts in an `Alert` table when suspicious changes are detected (for example, more than 50% change).
- Includes a Python script to bulk load product records from CSV.
- Includes a Python script to poll alerts and send email notifications.

## Repository structure
- `Price_audit_system.sql`: main schema, trigger definitions, and test queries.
- `TRIGGER_MASTARY.sql`: additional trigger practice examples and activity log patterns.
- `Bulkinsetion.py`: loads `product.csv` rows into MySQL.
- `send_email.py`: checks recent alerts and sends email notifications.
- `product.csv`: sample input data for bulk insert.

## Tech stack
- MySQL (tables, triggers, JSON columns)
- Python
- pandas
- mysql-connector-python
- SMTP (Gmail in current script)

## How to run
1. Create a MySQL database (for example `trig`).
2. Run `Price_audit_system.sql` to create tables and triggers.
3. Install Python dependencies:
   ```bash
   pip install pandas mysql-connector-python
   ```
4. Update database and email credentials in Python scripts.
5. Run bulk load:
   ```bash
   python Bulkinsetion.py
   ```
6. Start alert polling:
   ```bash
   python send_email.py
   ```

## Notes
- Current scripts contain hardcoded credentials. Move credentials to environment variables before production use.
- The trigger logic and JSON-based audit records make this a strong learning project for SQL trigger design and operational audit trails.

## Future improvements
- Replace polling with event-driven notifications.
- Add unit tests for trigger behavior.
- Containerize MySQL + app scripts with Docker for reproducible setup.
