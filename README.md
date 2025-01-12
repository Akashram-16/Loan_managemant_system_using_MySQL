# Loan_managemant_system_using_MySQL
Smart Loan Manager is an advanced loan management system that automates customer categorization, interest calculations, and CIBIL score analysis. It integrates data from various sources, applies triggers, and delivers insights for efficient loan tracking, using filtered outputs and stored procedures to optimize decisions.

# Smart Loan Manager (Loan Management System) using MySQL
________________________________________
#Project Objective
The objective of the Smart Loan Manager is to create a comprehensive, dynamic loan management system that streamlines data analysis, interest calculations, customer categorization, and decision-making processes. The system integrates information from multiple datasets, applies automated triggers, and filters key insights to provide actionable outputs for efficient loan and customer management.
Key goals include:
•	Categorizing customers based on income and property area.
•	Automating interest calculations and CIBIL score-based decision-making.
•	Consolidating data from multiple sources into a unified structure.
•	Providing filtered insights through procedures for better loan tracking and management.
________________________________________
Datasets
1.	Customer Income Status
2.	Loan Status
3.	Customer Information
4.	Country and State Information
5.	Regional Information
________________________________________
Modules
1. Sheet 1: Customer Income Status
•	Import Table:
Import data related to customer income status.
•	Customer Categorization:
o	Criteria: 
	Applicant Income > 15,000 → Grade A
	Applicant Income > 9,000 → Grade B
	Applicant Income > 5,000 → Middle-Class Customer
	Otherwise → Low-Class Customer
o	Create a new table to store this categorization.
•	Monthly Interest Percentage Calculation:
o	Criteria for Interest Rate: 
	Applicant Income < 5,000 (Rural) → 3%
	Applicant Income < 5,000 (Semi-Rural) → 3.5%
	Applicant Income < 5,000 (Urban) → 5%
	Applicant Income < 5,000 (Semi-Urban) → 2.5%
	Otherwise → 7%
________________________________________
2. Interest Calculations
•	Create New Fields:
o	Calculate Monthly and Annual Interest Amounts based on Loan Amount.
o	Create a table named  “customer_interest_analysis”  to store these fields.
•	Connect Data:
o	Link this table with Sheet 2 (Loan Status) for integrated output.
________________________________________
3. Sheet 2: Loan Status
•	Row-Level Trigger for Loan Amount:
o	Criteria: 
	Loan Amount = NULL → Loan Still Processing.
•	Statement-Level Trigger for CIBIL Score:
o	Criteria: 
	CIBIL Score > 900 → High CIBIL Score.
	CIBIL Score > 750 → No Penalty.
	CIBIL Score > 0 → Penalty Customers.
	CIBIL Score ≤ 0 → Reject Customers (Loan Cannot Be Applied).
•	Post-Processing:
o	Delete customers with Rejected and Loan Still Processing statuses.
o	Update loan amounts as integers.
•	Consolidate Data:
o	Store all fields in a table named loan_cibil_score_status_details.
________________________________________
4. Sheet 3: Customer Information
•	Import Table:
Import data from the customer info sheet.
•	Update Data:
Update gender and age based on Customer ID.
________________________________________
5. Sheets 4 & 5: Country, State, and Regional Information
•	Import Tables:
Import country, state, and regional datasets.
•	Data Consolidation:
o	Join all five tables without repeating fields.
________________________________________
Expected Outputs
Output 1:
A unified dataset consolidating information from all five tables.
Output 2:
Mismatched data details identified using joins.
Output 3:
Filter and display customers with high CIBIL scores.
Output 4:
Filter and display customers based on types (Home, Office, Corporate).
________________________________________
Additional Features
•	Stored Procedures:
Store all outputs as procedures for efficient data retrieval.
________________________________________

