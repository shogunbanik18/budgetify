drop table finance_insights.april_2024 ;
drop table finance_insights.may_2024 ;
drop table finance_insights.june_2024 ;
drop table finance_insights.july_2024 ;

truncate table finance_insights.july_2024 ;
-----------
update finance_insights.july_2024 set category ='invest' where expense_tracker = 'LIC';
select *,sum(expected_budget) over(order by j.record_date) as cum_budget, sum(amount) over(order by j.record_date) as cum_sum from finance_insights.july_2024 j where j.category = 'needs' and payment_status ='success';
select *,sum(amount) over(order by j.record_date) as cum_sum from finance_insights.july_2024 j where j.category ='invest';


select * from finance_insights.july_2024 j where j.category  = 'needs' and j.amount > j.expected_budget ;


--------------------

select * from finance_insights.july_2024 j ;
select * from finance_insights.june_2024 j ;
select * from finance_insights.may_2024 m ;
select * from finance_insights.april_2024 a ;
select * from finance_insights.august_2024 a;

select * from finance_insights.july_2024 j where j.category  = 'needs' or j.category = 'invest';
update finance_insights.july_2024 set category = 'invest' where expense_tracker= 'LIC'; 

select sum(amount) from finance_insights.july_2024 j where j.category in ('needs','invest');

select *,(j.amount-j.expected_budget) as extra_amount from finance_insights.july_2024 j where j.category  = 'needs' and j.amount>j.expected_budget ;

select column_name,data_type  from information_schema.columns where table_schema  = 'finance_insights' and table_name ='july_2024' ;
update finance_insights.july_2024  set amount = 3000 where expense_tracker  = 'Gym';

-----------
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'finance_insights';


--July_2024
select * from finance_insights.july_2024 j ;

--June_2024

--DROP TABLE finance_insights.june_2024;

CREATE TABLE finance_insights.june_2024 (
	expense_tracker varchar(200),
	amount float,
	payment_status varchar(100),
	transaction_type varchar(100),
	record_date text
);


select * from finance_insights.june_2024 j ;



update finance_insights.june_2024  set amount=0 where amount is NULL;

select expense_tracker,sum(amount) from finance_insights.june_2024 a where a.transaction_type = 'Investment' group by 1 ;

select * from finance_insights.june_2024 a where a.payment_status ='success' and a.transaction_type = 'Investment';
