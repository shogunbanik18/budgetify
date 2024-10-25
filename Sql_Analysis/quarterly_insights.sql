-- Quarterly analysis 
create or replace view finance_insights_wrk.q1_investments as (select * from finance_insights_wrk.april_2024 a union select * from finance_insights_wrk.may_2024 m union select * from finance_insights_wrk.june_2024 j);

select *,sum(expected_budget) over(order by expense_tracker) as cum_budget, sum(amount) over(order by expense_tracker) as cum_amount from finance_insights_wrk.q1_investments where category in ('invest') and transaction_type in ('investment') ;


create or replace view finance_insights_wrk.q2_investments as (select * from finance_insights_wrk.july_2024 j union select * from finance_insights_wrk.august_2024 a);
select *,sum(expected_budget) over(order by record_date,amount) as cum_budget, sum(amount) over(order by record_date,amount) as cum_amount from finance_insights_wrk.q2_investments where category in ('invest') and transaction_type in ('investment') and expense_tracker not in ('sip investment part 2') order by file_nm desc;

--drop view finance_insights_wrk.q2_investments ;

select *,sum(expected_budget) over(partition by file_nm order by record_date) as cum_budget, sum(amount) over(partition by file_nm order by record_date) as cum_amount from finance_insights_wrk.q2_investments where category in ('needs');

--quaterly analysis 
--######### Q1

create or replace VIEW  finance_insights_wrk.q1_investments as (
select * from finance_insights_wrk.april_2024 a where a.financial_category in ('invest') and a.transaction_type in ('investment')
union
select * from finance_insights_wrk.may_2024 m where m.financial_category in ('invest') and m.transaction_type in ('investment')
union
select * from finance_insights_wrk.june_2024 j where j.financial_category in ('invest') and j.transaction_type in ('investment')
);

select *,sum(expected_budget) over(order by record_date,amount) as cum_budget, sum(amount) over(order by record_date,amount) as cum_amount from finance_insights_wrk.q1_investments;

create or replace VIEW  finance_insights_wrk.q1_expenses as (
select * from finance_insights_wrk.april_2024 a where a.transaction_type in ('expense') and a.amount <> 0
union
select * from finance_insights_wrk.may_2024 m where m.transaction_type in ('expense') and m.amount <> 0
union
select * from finance_insights_wrk.june_2024 j where j.transaction_type in ('expense') and j.amount <> 0
); 

--total expense in q1 
select *,sum(expected_budget) over( order by record_date) as cum_budget, sum(amount) over( order by record_date) as cum_amount from finance_insights_wrk.q1_expenses;

--total expense in q2 
select *,sum(expected_budget) over(partition by file_nm order by record_date) as cum_budget, sum(amount) over(partition by file_nm order by record_date) as cum_amount from finance_insights_wrk.q1_expenses;

--for april month 
with april_2024_expenses as (
select file_nm,expense_category,expected_budget,amount,(amount-expected_budget) as diff_amount ,sum(expected_budget) over(partition by file_nm order by record_date) as cum_budget, sum(amount) over(partition by file_nm order by record_date) as cum_amount from finance_insights_wrk.q1_expenses where q1_expenses.file_nm in ('april_2024') and amount>expected_budget),
may_2024_expenses as (
select file_nm,expense_category,expected_budget,amount,(amount-expected_budget) as diff_amount ,sum(expected_budget) over(partition by file_nm order by record_date) as cum_budget, sum(amount) over(partition by file_nm order by record_date) as cum_amount from finance_insights_wrk.q1_expenses where q1_expenses.file_nm in ('may_2024') and amount>expected_budget),
june_2024_expenses as (
select file_nm,expense_category,expected_budget,amount,(amount-expected_budget) as diff_amount ,sum(expected_budget) over(partition by file_nm order by record_date) as cum_budget, sum(amount) over(partition by file_nm order by record_date) as cum_amount from finance_insights_wrk.q1_expenses where q1_expenses.file_nm in ('june_2024') and amount>expected_budget),
all_expenses AS (
    SELECT * FROM april_2024_expenses
    UNION ALL
    SELECT * FROM may_2024_expenses
    UNION ALL
    SELECT * FROM june_2024_expenses
)SELECT 
    *,file_nm,
    SUM(diff_amount) OVER (ORDER BY file_nm) AS extras,
    SUM(diff_amount) OVER () AS total_diff_amount
FROM 
    all_expenses;
select *,file_nm,sum(diff_amount) over(order by expense_category) as extras from june_2024_expenses union all
select *,file_nm,sum(diff_amount) over(order by expense_category) as extras from may_2024_expenses union all
select *,file_nm,sum(diff_amount) over(order by expense_category) as extras from april_2024_expenses;


--########## Q2 

create or replace VIEW  finance_insights_wrk.q2_investments as (
select * from finance_insights_wrk.july_2024 j where j.financial_category in ('invest') and j.transaction_type in ('investment')
union
select * from finance_insights_wrk.august_2024 a where a.financial_category in ('invest') and a.transaction_type in ('investment')
);


select *,sum(expected_budget) over(order by record_date,amount) as cum_budget, sum(amount) over(order by record_date,amount) as cum_amount from finance_insights_wrk.q2_investments;



