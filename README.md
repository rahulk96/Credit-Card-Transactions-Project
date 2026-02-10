# Credit-Card-Transactions-Project

End-to-end credit card analytics solution using SQL Server and Power BI, from raw CSV ingestion to executive dashboards.


Dataset Link- https://www.kaggle.com/datasets/thedevastator/analyzing-credit-card-spending-habits-in-india  


The dataset consists of credit card transaction–level data, where each record represents a single transaction.

Key attributes include:

transaction_id – Unique identifier for each transaction (Primary Key)

transaction_date – Date of transaction

city – City where the transaction occurred

card_type – Type of credit card (e.g., Gold, Silver, Platinum, Signature)

exp_type – Expense category (e.g., Fuel, Travel, Shopping)

amount – Transaction amount

gender – Customer gender



**🛠 Tech Stack**

Database: Microsoft SQL Server

Visualization: Power BI

Data Ingestion: Bulk Insert (CSV → SQL Server)

Version Control & Documentation: GitHub


-------------------------------------------------------

📊 Credit Card Transactions Analytics (SQL Server + Power BI)
📌 Business Problem

Credit card companies generate millions of transactions across cities, card types, and customer segments.
However, without structured analytics, it becomes difficult to answer key business questions such as:

Which cities and markets drive the most revenue?

Which card types contribute the highest spend?

How does customer spending behavior vary by gender and expense category?

Are transactions growing consistently over time, or are there signs of slowdown?

Objective:
To analyze credit card transaction data and uncover spending patterns across cities, card types, and customer segments, enabling stakeholders to identify high-value markets, optimize card offerings, and support data-driven strategic decisions.

🗂 Dataset Overview

The dataset consists of credit card transaction–level data, where each record represents a single transaction.

Key attributes include:

transaction_id – Unique identifier for each transaction (Primary Key)

transaction_date – Date of transaction

city – City where the transaction occurred

card_type – Type of credit card (e.g., Gold, Silver, Platinum, Signature)

exp_type – Expense category (e.g., Fuel, Travel, Shopping)

amount – Transaction amount

gender – Customer gender

Grain: One row per transaction
Time Coverage: Multi-year transactional history

🛠 Tech Stack

Database: Microsoft SQL Server

Data Modeling & Analytics: SQL (CTEs, Window Functions, Views)

Visualization: Power BI

Data Ingestion: Bulk Insert (CSV → SQL Server)

Version Control & Documentation: GitHub

🏗 Analytics Architecture

The project follows a layered analytics architecture, similar to real-world analytics teams.

1️⃣ Raw & Clean Layer (SQL Server)

Raw data ingested into staging tables

Data validation, null checks, and primary key enforcement

Cleaned fact table created for analytics

2️⃣ Analytics Layer (SQL Views)

All business logic is centralized in SQL views, including:

KPI summaries

Monthly performance metrics

City-wise spend contribution

Card type and gender segmentation

Ranking and growth metrics (MoM)

This ensures:

Reusability across reports

Consistent metric definitions

Better performance in Power BI

3️⃣ Visualization Layer (Power BI)

Power BI connects only to analytics views

Minimal DAX used for dynamic, filter-aware KPIs

Interactive dashboards built for business users

📈 Key Insights

Some of the key insights derived from the analysis include:

A small number of cities contribute a disproportionately large share of total credit card spend.

Premium card types (e.g., Platinum, Signature) show higher average transaction values, even with fewer transactions.

Certain expense categories dominate spending consistently across cities.

Clear monthly spending trends reveal periods of growth and slowdown.

Gender-based segmentation highlights differences in spending behavior and transaction frequency.

📊 Power BI Dashboard

The Power BI dashboard is designed for executive and business users, focusing on clarity and decision-making.

Dashboard pages include:

Executive Summary: Total spend, transactions, and average ticket size

Time Analysis: Monthly trends and growth patterns

Geographical Analysis: City-wise and market contribution

Card & Customer Segmentation: Card type and gender insights

📷 Dashboard screenshots can be found in the /dashboard_screenshots folder.

🚀 Project Highlights

End-to-end analytics project from raw CSV to executive dashboard

Strong separation of SQL analytics logic and Power BI visualization

Advanced SQL techniques (CTEs, window functions, rankings, growth metrics)

Realistic business framing suitable for interviews and portfolios
