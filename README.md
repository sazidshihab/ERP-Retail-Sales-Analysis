## 📁 Repository Structure

📊 ERPBoss — Sales Analytics

ERPBoss is a complete sales analytics pipeline that transforms ERP data into actionable KPIs and visual insights through Tableau.
It includes raw-to-refined data cleaning, SQL-based KPI computation, and a ready-to-use Tableau dashboard.

🗂️ Repository Structure
.
├─ Data from ERP server/
│  ├─ Cleaning.ipynb
│  ├─ loading erpboss table.sql
│  ├─ refined_department_sale.csv
│  ├─ refined_department_sale_0.xlsx
│  ├─ refined_department_sale_1000000.xlsx
│  ├─ refined_stock_item_sale.csv
│  ├─ refined_stock_items.csv
│  └─ refined_supplier_invoice.csv
│
├─ SQL/
│  ├─ base analysis erpboss.sql
│  ├─ sale analysis.sql
│  └─ sale deep analysis.sql
│
├─ data_for_tableau_1.csv
├─ data_for_tableau_2.csv
└─ sale_analyze.twb

⚙️ Pipeline Overview

Raw → Cleaning → SQL → KPI Table → CSV → Tableau Dashboard

1. 🧹 Cleaning

Data from ERP server/Cleaning.ipynb

Cleans raw ERP exports

Produces the refined_*.csv/.xlsx files used in later steps

2. 🗄️ Loading

Data from ERP server/loading erpboss table.sql

Loads refined CSV/XLSX files into staging tables in your database

3. 🧮 Analysis

SQL Scripts (run in this order):

base analysis erpboss.sql — creates base staging and cleaned tables

sale analysis.sql — builds fact/dimension tables and aggregates

sale deep analysis.sql — produces the main KPI table (sales_kpi_main)

4. 📤 Export

Export sales_kpi_main to:

data_for_tableau_1.csv

data_for_tableau_2.csv

5. 📊 Visualization

Open sale_analyze.twb in Tableau Desktop

Point it to the CSVs (or connect live to the DB)

Refresh extracts to view the Sales KPI Dashboard

📌 KPIs Generated

All KPIs are computed per product (stock_code).

Category	KPI Fields
Product Metrics	stock_code, recency, frequency, total_quantity, total_revenue, total_gross_profit, gross_profit_per_product, gross_profit_margin
RFM & Scores	rfm_score, rfm_score_score, revenue_score, quantity_score, gross_profit_per_product_score, gross_profit_percentage_score, final_score
Yearly Trend Metrics	quantity->1 to quantity->15 (2006–2025), 2006-profit … 2025-profit, 2006-YoY … 2025-YoY
Cumulative Metrics	gross_profit_percentage, cumulative_profit, cumulative_profit_percentage

Year Index Mapping
quantity->1 = 2006, quantity->2 = 2007 … quantity->15 = 2025

This structure allows product-level trend analysis across multiple years, growth calculations, and scoring-based prioritization.

📈 Tableau Dashboard

File: sale_analyze.twb
Contains:

RFM segmentation

Profitability vs Quantity scatter plots

Top revenue & profit products

Year-over-year and cumulative trends

KPI-based ranking using final_score

🔁 Update Workflow

Place new raw ERP exports

Run Cleaning.ipynb to regenerate refined files

Run loading erpboss table.sql to load data into the DB

Run the 3 SQL scripts (base → sale → sale deep)

Export the main KPI table to the two CSVs

Open sale_analyze.twb → Refresh Extracts

✅ Best Practices

Keep consistent column names, types, and formats in refined data

Deduplicate and normalize product/supplier IDs

Always rebuild KPI table fully before export

Add a build_timestamp field to track data refreshes

🤝 Contributing

Contributions, issues, and feature requests are welcome.
Please describe data changes, KPI impacts, and Tableau impacts clearly.

📄 License

Copyright © 2025 Sazid.data — All Rights Reserved

This project and its contents are proprietary and confidential.
No part of this project may be copied, modified, distributed, published, or used in any form without the prior written permission of the author.
