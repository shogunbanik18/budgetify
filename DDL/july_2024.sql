-- finance_insights.july_2024 definition

-- Drop table

-- DROP TABLE finance_insights.july_2024;

CREATE TABLE finance_insights.july_2024 (
	expense_tracker varchar(200) ,
	expected_budget  int ,
	amount int ,
	payment_status varchar(200) ,
	transaction_type varchar(200)  ,
	record_date timestamp 
);

-- Permissions

ALTER TABLE finance_insights.july_2024 OWNER TO postgres;
GRANT ALL ON TABLE finance_insights.july_2024 TO postgres;