# Monday-Coffee-Project
## Project Overview
This project provides a data-driven analysis for **Monday Coffee**, focusing on sales performance and identifying the best cities for new store openings. The analysis integrates population data, rental costs, and transaction history.

## Database Schema
The project uses a relational database with four main tables:
* **City:** Demographics and rental data.
* **Customers:** Unique customer identifiers and city mapping.
* **Products:** Coffee product catalog and pricing.
* **Sales:** Transactional data including ratings and revenue.

## Key Insights from the Analysis
Based on the SQL queries in `monday_coffee_data_analysis_queries.sql`, here are the top findings:

### 1. Market Potential (Top Cities)
* Identified cities where the estimated coffee consumer base (25% of population) is highest.
* **Top Cities by Population:** Bangalore, Delhi, and Mumbai.

### 2. Top Selling Products
* The analysis identifies which products drive the most revenue (e.g., Cold Brew vs. Ground Espresso).

### 3. Expansion Recommendations
* By calculating the **Average Rent per Customer**, we identified the most "cost-efficient" cities for new store locations.

## How to Reproduce
1. Run `monday_coffee_schemas_database_setup.sql` to create the schema.
2. Import the `.csv` files from the `data/` folder into the respective tables.
3. Run `monday_coffee_data_analysis_queries.sql` to generate the reports.
