-- LOAN MANAGEMENT SYSTEM

/* This DATABASE involves to manage & analyze the data about customer_details and their loan status.
   I have created new attributes AND New table by using the main source. 

-- SOURCE TABLES
    1.customer_income_details
    2.loan_details
    3.Customer_information
    4.Country_state
    5.region_info
*/

CREATE DATABASE loan_ms; 
USE loan_ms;

-- A customer income details data has been imported.
ALTER TABLE customer_income RENAME customer_income_details;

-- Altering the incorrect column names and datatypes. 
ALTER TABLE customer_income_details 
MODIFY loan_id VARCHAR(30),
CHANGE COLUMN `Customer ID` customer_id VARCHAR(30),
CHANGE COLUMN Applicantincome Applicant_income INT,
CHANGE COLUMN Coapplicantincome Co_applicant_income INT,
MODIFY Property_Area VARCHAR(30),
MODIFY Loan_Status VARCHAR(30);

SELECT * FROM customer_income_details;

-- Creating a new table with "customer_criteria & Monthly_interest_percentage" by using the 'customer_income_details' table.
SELECT * FROM customer_income_details;

CREATE TABLE customer_criteria_intrstpct
SELECT *,
CASE
    WHEN Applicant_income > 15000 THEN "A - grade"
    WHEN Applicant_income > 9000 THEN "B - grade"
    WHEN Applicant_income > 5000 THEN "Middle class customer"
    ELSE "Low class customer"
END AS 'Customer_criteria',
CASE
    WHEN Applicant_income < 5000 AND Property_area='Rural' THEN 3
    WHEN Applicant_income < 5000 AND Property_area='Semirural' THEN 3.5
    WHEN Applicant_income < 5000 AND Property_area='Urban' THEN 5
    WHEN Applicant_income < 5000 AND property_area='Semiurban' THEN 2.5
    ELSE 7
END AS 'Monthly_interest_pct'
FROM customer_income_details;

SELECT * FROM customer_criteria_intrstpct;

-- Loan details table has been imported and insertrd the table's whole data into "customer_loan_status" which was created below:
-- "Row level & statement level" triggers are created for this table.

CREATE TABLE Customer_loan_status(Loan_id VARCHAR(30),
								  Customer_id VARCHAR(30),
                                  Loan_amount VARCHAR(30),
                                  Loan_amount_term INT,
                                  Cibil_score INT);

-- This table manages cibil_score's status by using statement level trigger;
CREATE TABLE Cibil_remarks(Loan_id VARCHAR(30),
                           Customer_id VARCHAR(30),
                           Cibil_score INT,
                           Cibil_score_status VARCHAR(30));
                           
-- Row level trigger in 'customer_loan_status' table.
DELIMITER //
CREATE TRIGGER Loan_amount_process BEFORE INSERT ON customer_loan_status
FOR EACH ROW

BEGIN
    IF NEW.Loan_amount IS NULL THEN 
    SET NEW.Loan_amount="Loan still processing";
    END IF;
END //
DELIMITER ;

-- Statement level trigger in 'customer_loan_status' to 'Cibil_remarks'.
DELIMITER //
CREATE TRIGGER Remarking_cibil AFTER INSERT ON customer_loan_status 
FOR EACH ROW

BEGIN
     IF NEW.Cibil_score>900 THEN
     INSERT INTO Cibil_remarks(loan_id,customer_id,cibil_score,cibil_score_status)
     VALUES(NEW.loan_id,NEW.customer_id,NEW.cibil_score,"High cibil score");
     
     ELSEIF NEW.Cibil_score>750 THEN 
     INSERT INTO Cibil_remarks(Loan_id,customer_id,cibil_score,cibil_score_status)
     VALUES(NEW.Loan_id,NEW.customer_id,NEW.cibil_score,"No penalty");
     
     ELSEIF NEW.Cibil_score>0 THEN
     INSERT INTO Cibil_remarks(loan_id,customer_id,cibil_score,cibil_score_status)
     VALUES(NEW.loan_id,NEW.customer_id,NEW.cibil_score,"Penalty customer");
     
     ELSEIF NEW.Cibil_score<=0 THEN
     INSERT INTO Cibil_remarks(loan_id,customer_id,cibil_score,cibil_score_status)
     VALUES(NEW.loan_id,NEW.customer_id,NEW.cibil_score,"Rejected customer");
     
     END IF;
END // 
DELIMITER ;


SHOW TRIGGERS;

-- INSERTING DATA INTO 'Customer_loan_status' from 'loan_status'.
INSERT INTO customer_loan_status
SELECT * FROM Loan_status;

-- Retriving the data to ensure the trigger execution.
SELECT * FROM customer_loan_status;
SELECT * FROM  cibil_remarks;

-- Deleting loan status table (the whole data was inserted in "customer_loan_status.")
DROP TABLE loan_status;
 
/* deleting the rejected and loan still processing customer details & set a datatype integer to loan_amount 
   then creating as a new table "loan cibil score details".*/
   
CREATE TABLE Loan_cibilscore_status_details
SELECT cls.*,
       cr.Cibil_score_status
FROM customer_loan_status cls 
INNER JOIN Cibil_remarks cr
ON cls.customer_id=cr.customer_id
WHERE Loan_amount!='Loan still processing' 
HAVING cibil_score_status!='rejected customer';

-- Ensure the data
SELECT * FROM loan_cibilscore_status_details;
ALTER TABLE loan_cibilscore_status_details MODIFY Loan_amount DECIMAL(10,2);

/* Calculating monthly & annual interrest amount based on loan amount and 
   creating the data as a new table 'customer_interest_analysis'.*/
   
SELECT * FROM loan_cibilscore_status_details;
SELECT * FROM customer_criteria_intrstpct;

CREATE TABLE Customer_interest_analysis
SELECT cct.Loan_id,
	   cct.Customer_id,
       cct.Applicant_income,
       cct.Property_area,
       cct.customer_criteria,
       lc.Loan_amount,
       lc.loan_amount_term,
       cct.monthly_interest_pct,
       lc.cibil_score,
       round(lc.Loan_amount * cct.monthly_interest_pct/100*1,2) AS 'Monthly_interest_amount',
       round(lc.Loan_amount * cct.monthly_interest_pct/100*12,2) AS 'Annual_interest_amount'
FROM customer_criteria_intrstpct cct
INNER JOIN loan_cibilscore_status_details lc
ON cct.Customer_id=lc.customer_id;

-- Ensuring the data
SELECT * FROM customer_interest_analysis;

-- A customer basic information table has been imported & ensuring the data.
 ALTER TABLE Customer_det RENAME Customer_information;
 SELECT * FROM Customer_information;
 
 -- Modifying correct datatypes
 ALTER TABLE customer_information 
 CHANGE COLUMN `Customer ID` Customer_id VARCHAR(30),
 MODIFY Customer_name VARCHAR(50),
 MODIFY Gender VARCHAR(10),
 MODIFY Married VARCHAR(10),
 MODIFY Education VARCHAR(25),
 MODIFY Self_employed VARCHAR(5),
 MODIFY Loan_id VARCHAR(20),
 MODIFY Region_id FLOAT;
 
 SELECT * FROM customer_information;
 
-- Updating some data in customer information table -- case end

UPDATE customer_information
SET Gender=
CASE
    WHEN Customer_id='IP43006' THEN "Female"
    WHEN Customer_id='IP43016' THEN "Female"
    WHEN Customer_id='IP43018' THEN "Male"
    WHEN Customer_id='IP43038' THEN "Male"
    WHEN Customer_id='IP43508' THEN "Female"
    WHEN Customer_id='IP43577' THEN "Female"
    WHEN Customer_id='IP43589' THEN "Female"
    WHEN Customer_id='IP43593' THEN "Female"
END
WHERE customer_id in ('ip43006','IP43016','IP43018','IP43038','IP43508','IP43577','IP43589','IP43593');

UPDATE customer_information
set Age=
CASE
    WHEN Customer_id='IP43007' THEN 45
    WHEN Customer_id='IP43009' THEN 32
END
WHERE customer_id in ("IP43007","IP43009");

SELECT * FROM customer_information;
-- imported country & region tables
ALTER TABLE Country_state
   MODIFY Customer_id VARCHAR(25),
   CHANGE COLUMN `Load Id` Loan_id VARCHAR(20),
   MODIFY Customer_name VARCHAR(50),
   MODIFY Region_id FLOAT,
   MODIFY Segment VARCHAR(20),
   MODIFY State VARCHAR(30);

ALTER TABLE Region_info
   MODIFY Region VARCHAR(10),
   MODIFY Region_id FLOAT;

SELECT * FROM Country_state;
SELECT * FROM Region_info;

-- Creating stored procedure to get certain results:

DELIMITER //
CREATE PROCEDURE Customer_loan_info()
BEGIN
-- Customer's full details:
   SELECT T1.Customer_id,T1.Loan_id,T1.customer_name,T1.Gender,T1.Age,T1.Married,T1.Education,T1.Self_Employed,
          T2.Applicant_Income,T2.Co_applicant_Income,T2.Property_Area,T2.Loan_Status,T2.Customer_criteria,T2.Monthly_interest_pct,
          T3.Loan_amount,T3.Loan_Amount_Term,T3.Cibil_Score,T6.Cibil_score_status,T3.Monthly_interest_amount,T3.Annual_interest_amount,
		  T4.Postal_Code,T4.Segment,T4.State,
          T5.Region_id,T5.Region
   FROM customer_information T1
   INNER JOIN customer_criteria_intrstpct T2
   ON T1.Customer_ID=T2.customer_ID
   INNER JOIN customer_interest_analysis T3
   ON T3.customer_ID=T1.Customer_ID
   INNER JOIN country_state T4
   ON T4.Customer_id=T1.Customer_ID
   INNER JOIN region_info T5
   ON T5.Region_Id=T1.Region_id
   INNER JOIN loan_cibilscore_status_details T6
   ON T6.Customer_id=T3.Customer_id;

-- Customers who have not gotten a loan amount & rejected customers:
   SELECT T1.Customer_id,T1.Loan_id,T1.customer_name,T1.Gender,T1.Age,T1.Married,T1.Education,T1.Self_Employed,
          T2.Applicant_Income,T2.Co_applicant_Income,T2.Property_Area,T2.Loan_Status,T2.Customer_criteria,T2.Monthly_interest_pct,
          T3.Loan_amount,T3.Loan_Amount_Term,T3.Cibil_Score,T6.Cibil_score_status,T3.Monthly_interest_amount,T3.Annual_interest_amount,
		  T4.Postal_Code,T4.Segment,T4.State,
          T5.Region_id,T5.Region
   FROM customer_information T1
   LEFT JOIN customer_criteria_intrstpct T2
   ON T1.Customer_ID=T2.customer_ID
   LEFT JOIN customer_interest_analysis T3
   ON T3.customer_ID=T1.Customer_ID
   LEFT JOIN country_state T4
   ON T4.Customer_id=T1.Customer_ID
   LEFT JOIN region_info T5
   ON T5.Region_Id=T1.Region_id
   LEFT JOIN loan_cibilscore_status_details T6
   ON T6.Customer_id=T3.Customer_id
   WHERE T3.Loan_amount IS NULL
   ORDER BY T1.Customer_id ASC;

-- Customers who has high cibil score:
   SELECT T1.Customer_id,T1.Loan_id,T1.customer_name,T1.Gender,T1.Age,T1.Married,T1.Education,T1.Self_Employed,
          T2.Applicant_Income,T2.Co_applicant_Income,T2.Property_Area,T2.Loan_Status,T2.Customer_criteria,T2.Monthly_interest_pct,
          T3.Loan_amount,T3.Loan_Amount_Term,T3.Cibil_Score,T6.Cibil_score_status,T3.Monthly_interest_amount,T3.Annual_interest_amount,
		  T4.Postal_Code,T4.Segment,T4.State,
          T5.Region_id,T5.Region
   FROM customer_information T1
   INNER JOIN customer_criteria_intrstpct T2
   ON T1.Customer_ID=T2.customer_ID
   INNER JOIN customer_interest_analysis T3
   ON T3.customer_ID=T1.Customer_ID
   INNER JOIN country_state T4
   ON T4.Customer_id=T1.Customer_ID
   INNER JOIN region_info T5
   ON T5.Region_Id=T1.Region_id
   INNER JOIN loan_cibilscore_status_details T6
   ON T6.Customer_id=T3.Customer_id
   WHERE T6.cibil_score_status='High cibil score'
   ORDER BY T1.Customer_id ASC;
  
-- Customers who has segment as 'corporate & home office':
   SELECT T1.Customer_id,T1.Loan_id,T1.customer_name,T1.Gender,T1.Age,T1.Married,T1.Education,T1.Self_Employed,
          T2.Applicant_Income,T2.Co_applicant_Income,T2.Property_Area,T2.Loan_Status,T2.Customer_criteria,T2.Monthly_interest_pct,
          T3.Loan_amount,T3.Loan_Amount_Term,T3.Cibil_Score,T6.Cibil_score_status,T3.Monthly_interest_amount,T3.Annual_interest_amount,
		  T4.Postal_Code,T4.Segment,T4.State,
          T5.Region_id,T5.Region
   FROM customer_information T1
   INNER JOIN customer_criteria_intrstpct T2
   ON T1.Customer_ID=T2.customer_ID
   INNER JOIN customer_interest_analysis T3
   ON T3.customer_ID=T1.Customer_ID
   INNER JOIN country_state T4
   ON T4.Customer_id=T1.Customer_ID
   INNER JOIN region_info T5
   ON T5.Region_Id=T1.Region_id
   INNER JOIN loan_cibilscore_status_details T6
   ON T6.Customer_id=T3.Customer_id
   WHERE Segment IN('Corporate','Home Office')
   ORDER BY T1.Customer_id ASC;

END //
DELIMITER ;

-- CALL THE PROCEDURE TO GET OUTPUTS
CALL Customer_loan_info();


-- Procedure to find a particular customer's data
DELIMITER //
CREATE PROCEDURE FIND_CUSTOMER_DATA
(IN CUS_ID VARCHAR(20))

BEGIN
-- To calculate total customers
     SELECT COUNT(DISTINCT(Customer_id)) AS 'Total customers'
     FROM Customer_information;
     
-- To find a secific customer data
   SELECT T1.Customer_id,T1.Loan_id,T1.customer_name,T1.Gender,T1.Age,T1.Married,T1.Education,T1.Self_Employed,
          T2.Applicant_Income,T2.Co_applicant_Income,T2.Property_Area,T2.Loan_Status,T2.Customer_criteria,T2.Monthly_interest_pct,
          T3.Loan_amount,T3.Loan_Amount_Term,T3.Cibil_Score,T6.Cibil_score_status,T3.Monthly_interest_amount,T3.Annual_interest_amount,
		  T4.Postal_Code,T4.Segment,T4.State,
          T5.Region_id,T5.Region
   FROM customer_information T1
   LEFT JOIN customer_criteria_intrstpct T2
   ON T1.Customer_ID=T2.customer_ID
   LEFT JOIN customer_interest_analysis T3
   ON T3.customer_ID=T1.Customer_ID
   LEFT JOIN country_state T4
   ON T4.Customer_id=T1.Customer_ID
   LEFT JOIN region_info T5
   ON T5.Region_Id=T1.Region_id
   LEFT JOIN loan_cibilscore_status_details T6
   ON T6.Customer_id=T3.Customer_id
   WHERE T1.Customer_id=CUS_ID;
END //
DELIMITER ;

CALL Find_customer_info('IP43557');
CALL Find_customer_info('IP43604');
CALL Find_customer_info('IP43610');
CALL Find_customer_info('IP43010');

-- END SCRIPT