create or replace view finance_insights_wrk.q1 as (
select * from finance_insights_wrk.april_2024 a union
select * from finance_insights_wrk.may_2024 m union
select * from finance_insights_wrk.june_2024 s);

create or replace view finance_insights_wrk.q2 as (
select * from finance_insights_wrk.july_2024 a union
select * from finance_insights_wrk.august_2024 m union
select * from finance_insights_wrk.september_2024 s);

create or replace view finance_insights_wrk.q3 as (
select * from finance_insights_wrk.october_2024 a union
select * from finance_insights_wrk.november_2024 m union
select * from finance_insights_wrk.december_2024 d);

create or replace view finance_insights_wrk.q4 as (
select * from finance_insights_wrk.january_2025 a union
select * from finance_insights_wrk.february_2025 m union
select * from finance_insights_wrk.march_2025 d);
---------------------------

--drop view finance_insights_wrk.quarterly;

create or replace view finance_insights_wrk.quarterly as (
select * from finance_insights_wrk.q1 union 
select * from finance_insights_wrk.q2 union 
select * from finance_insights_wrk.q3
);

select *,sum(amount) over(order by file_nm desc ) as monthly_results from finance_insights_wrk.quarterly;

----------
--q1
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q1;
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q1 where finance_insights_wrk.q1.financial_category in ('needs');
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q1 where finance_insights_wrk.q1.financial_category in ('wants');
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q1 where finance_insights_wrk.q1.financial_category in ('invest');

--q2
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q2;
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q2 where finance_insights_wrk.q2.financial_category in ('needs');
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q2 where finance_insights_wrk.q2.financial_category in ('wants');
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q2 where finance_insights_wrk.q2.financial_category in ('invest');


--q3
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q3;
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q3 where finance_insights_wrk.q3.financial_category in ('needs');
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q3 where finance_insights_wrk.q3.financial_category in ('wants');
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q3 where finance_insights_wrk.q3.financial_category in ('invest');

--## q3 end to end analysis 
select 
sum(case when financial_category='needs' then amount else 0 end) as total_needs,
sum(case when financial_category='invest' then amount else 0 end) as total_investment,
sum(case when financial_category='wants' then amount else 0 end) as total_wants,
file_nm as file_name
from finance_insights_wrk.q3 group by file_nm ;

-- q4
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q4;
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q4 where finance_insights_wrk.q4.financial_category in ('needs');
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q4 where finance_insights_wrk.q4.financial_category in ('wants');
select *,sum(amount) over(order by file_nm desc) from finance_insights_wrk.q4 where finance_insights_wrk.q4.financial_category in ('invest');
