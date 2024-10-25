create or replace view finance_insights_wrk.basic_needs as (
select a.expense_category ,a.expected_budget ,a.amount ,a.financial_category ,a.transaction_type,a.record_date,sum(expected_budget) over(order by record_date,amount) as cum_budget_transferred , sum(amount) over(order by record_date,amount) from finance_insights_int.august_2024 a  where a.financial_category not in ('invest','wants') and a.amount <> 0
)
