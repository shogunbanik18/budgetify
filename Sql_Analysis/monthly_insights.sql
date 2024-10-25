--1. "Savings Rate"
WITH fin_cte1 AS (
    SELECT 
        SUM(CASE WHEN transaction_type = 'investment' THEN amount ELSE 0 END) AS total_investment,
        SUM(CASE WHEN transaction_type = 'expense' THEN amount ELSE 0 END) AS total_expense
    FROM finance_insights_wrk.{month_year}
)
SELECT 
    total_investment, 
    total_expense, 
    ROUND((total_investment::NUMERIC / NULLIF((total_investment + total_expense)::NUMERIC, 0) * 100)::NUMERIC, 2) AS savings_rate 
FROM fin_cte1;

-- 2. Recurring vs. Non-Recurring Expenses
SELECT 
    * 
FROM finance_insights_wrk.{month_year};

-- 3. Expense Efficiency: Needs vs Wants
WITH fin_cte2 AS (
    SELECT 
        SUM(CASE WHEN financial_category = 'needs' THEN amount ELSE 0 END) AS total_needs,
        SUM(CASE WHEN financial_category = 'invest' THEN amount ELSE 0 END) AS total_invest,
        SUM(CASE WHEN financial_category = 'wants' THEN amount ELSE 0 END) AS total_wants
    FROM finance_insights_wrk.{month_year}
)
SELECT 
    total_needs, 
    total_invest, 
    total_wants, 
    ROUND((total_needs::NUMERIC / NULLIF((total_needs + total_wants + total_invest)::NUMERIC, 0) * 100)::NUMERIC, 2) AS needs_percentage,
    ROUND((total_invest::NUMERIC / NULLIF((total_needs + total_wants + total_invest)::NUMERIC, 0) * 100)::NUMERIC, 2) AS invest_percentage,
    ROUND((total_wants::NUMERIC / NULLIF((total_needs + total_wants + total_invest)::NUMERIC, 0) * 100)::NUMERIC, 2) AS wants_percentage
FROM fin_cte2;

-- 4. Daily Expense Comparison
-- Highest Daily Expense
SELECT 
    EXTRACT(DAY FROM record_date) AS day, 
    SUM(amount) AS daily_amount 
FROM finance_insights_wrk.{month_year} 
GROUP BY day 
ORDER BY daily_amount DESC 
LIMIT 1;

--5. Lowest Daily Expense
SELECT 
    EXTRACT(DAY FROM record_date) AS day, 
    SUM(amount) AS daily_amount 
FROM finance_insights_wrk.{month_year} 
GROUP BY day 
ORDER BY daily_amount ASC 
LIMIT 1;

--6. Weekly Analysis
WITH fin_cte3 AS (
    SELECT 
        expense_category,
        amount,
        record_date, 
        EXTRACT(DAY FROM record_date) AS day,
        CASE 
            WHEN EXTRACT(DAY FROM record_date) BETWEEN 1 AND 7 THEN 'week1'
            WHEN EXTRACT(DAY FROM record_date) BETWEEN 8 AND 14 THEN 'week2'
            WHEN EXTRACT(DAY FROM record_date) BETWEEN 15 AND 21 THEN 'week3'
            ELSE 'week4'
        END AS week
    FROM finance_insights_wrk.{month_year}
)
SELECT 
    week, 
    SUM(amount) AS total_amount 
FROM fin_cte3 
GROUP BY week order by week asc;

-- 7. Unexpected/Overbudget Expenses
SELECT 
    expense_category,
    expected_budget,
    amount,
    (amount - expected_budget)::NUMERIC AS extra,
    CASE 
        WHEN expected_budget ::NUMERIC<> 0 THEN ROUND(((amount - expected_budget)::NUMERIC / NULLIF(expected_budget, 0)::NUMERIC)::NUMERIC * 100::NUMERIC, 2)::NUMERIC 
        ELSE NULL 
    END AS extra_percent
FROM finance_insights_wrk.{month_year} 
WHERE amount::NUMERIC > expected_budget::NUMERIC;


-- 8. Daily Spending Variance from Budget
WITH fin_cte4 AS (
    SELECT 
        expense_category,
        expected_budget,
        amount,
        record_date,
        (expected_budget - amount) AS deviation 
    FROM finance_insights_wrk.{month_year}
)
SELECT 
    * 
FROM fin_cte4;

-- 9. Opportunity Cost Analysis
WITH fin_cte5 AS (
    SELECT 
        *,
        (amount - expected_budget) AS deviation 
    FROM finance_insights_wrk.{month_year} 
    WHERE financial_category = 'wants' AND amount <> 0
)
SELECT 
    SUM(deviation) AS opportunity_cost,
    'This amount could have been invested' AS investment_opportunity 
FROM fin_cte5;

-- 10. Psychological Spending Analysis
SELECT 
    *, 
    (amount - expected_budget) AS deviation 
FROM finance_insights_wrk.{month_year} 
WHERE financial_category = 'wants' AND amount <> 0;

-- 11. Needs, Wants, and Investment Distribution
SELECT 
    amount_data.financial_category,
    budget_data.total_budget,
    amount_data.total_amount,
    budget_data.budget_percent,
    amount_data.amount_percent 
FROM 
    (SELECT 
        financial_category,
        SUM(expected_budget::NUMERIC) AS total_budget,
        ROUND(
            (SUM(expected_budget::NUMERIC) / NULLIF((SELECT SUM(expected_budget::NUMERIC) FROM finance_insights_wrk.{month_year}), 0)) * 100,
            2
        ) AS budget_percent 
    FROM finance_insights_wrk.{month_year} 
    GROUP BY financial_category) AS budget_data
FULL OUTER JOIN 
    (SELECT 
        financial_category,
        SUM(amount::NUMERIC) AS total_amount,
        ROUND(
            (SUM(amount::NUMERIC) / NULLIF((SELECT SUM(amount::NUMERIC) FROM finance_insights_int.{month_year}), 0)) * 100,
            2
        ) AS amount_percent  
    FROM finance_insights_wrk.{month_year} 
    GROUP BY financial_category) AS amount_data 
ON budget_data.financial_category = amount_data.financial_category;


-- 12. Pending Payment Mode Status
SELECT 
    *, 
    SUM(expected_budget::NUMERIC) OVER (ORDER BY record_date, amount) AS cum_budget_transferred 
FROM finance_insights_int.{month_year} 
WHERE payment_status IN ('pending');

-- 13. 1st 15 Days vs Last 15 Days Expenses
WITH cte5 AS (
    SELECT 
        EXTRACT(DAY FROM record_date) AS day_of_month,
        *,
        CASE 
            WHEN EXTRACT(DAY FROM record_date) <= 15 THEN '1st 15 days' 
            ELSE 'Last 15 days' 
        END AS day_period
    FROM finance_insights_wrk.{month_year}
),
cte6 AS (
    SELECT 
        day_period,
        SUM(amount) AS total_amount 
    FROM cte5 
    GROUP BY day_period
)
SELECT 
    day_period,
    total_amount,
    ROUND((total_amount::NUMERIC / NULLIF(SUM(total_amount::NUMERIC) OVER (), 0)::NUMERIC) * 100, 2) AS percentage 
FROM cte6;

-- 14. Maximum Expense Category and its Percentage
WITH cte8 AS (
    SELECT 
        expense_category,
        SUM(amount) AS total_amount 
    FROM finance_insights_wrk.{month_year} 
    WHERE financial_category <> 'invest' 
    GROUP BY expense_category 
    ORDER BY total_amount DESC
)
SELECT 
    *, 
    ROUND((total_amount::NUMERIC / NULLIF(SUM(total_amount::NUMERIC) OVER (), 0)::NUMERIC) * 100, 2) AS Percentage_expense 
FROM cte8 
ORDER BY total_amount DESC 
LIMIT 1;

-- 15. Top N Expense Categories
WITH cte9 AS (
    SELECT 
        expense_category,
        SUM(amount) AS total_amount 
    FROM finance_insights_wrk.{month_year} 
    WHERE financial_category <> 'invest' 
    GROUP BY expense_category
)
SELECT 
    *, 
    ROUND((total_amount::NUMERIC / NULLIF(SUM(total_amount::NUMERIC) OVER (), 0)::NUMERIC) * 100, 2) AS Percentage_expense 
FROM cte9 
ORDER BY total_amount DESC 
LIMIT 7;

-- 16. Weekdays vs Weekends Spending
WITH cte_10 AS (
    SELECT 
        EXTRACT(DAY FROM record_date) AS day_,
        TO_CHAR(record_date, 'FMDay') AS day_name,
        *,
        CASE 
            WHEN TO_CHAR(record_date, 'FMDay') NOT IN ('Saturday', 'Sunday') THEN 'weekdays' 
            ELSE 'weekend' 
        END AS day_type
    FROM finance_insights_wrk.{month_year}
)
SELECT 
    day_type,
    SUM(amount) AS total_amount,
    ROUND(SUM(amount)::NUMERIC * 100.0 / NULLIF(SUM(SUM(amount)) OVER (), 0)::NUMERIC, 2) AS percentage 
FROM cte_10 
GROUP BY day_type;

-- 17. Category-wise Distribution by Day Type
WITH cte_11 AS (
    SELECT 
        EXTRACT(DAY FROM record_date) AS day_,
        TO_CHAR(record_date, 'FMDay') AS day_name,
        *,
        CASE 
            WHEN TO_CHAR(record_date, 'FMDay') NOT IN ('Saturday', 'Sunday') THEN 'weekdays' 
            ELSE 'weekend' 
        END AS day_type
    FROM finance_insights_wrk.{month_year}
)
SELECT 
    day_,
    day_name,
    expense_category,
    financial_category,
    transaction_type,
    amount,
    day_type,
    SUM(amount) OVER (PARTITION BY day_type ORDER BY day_) 
FROM cte_11;

-- To Be Analyzed:
-- Quarterly Analysis: High-Frequency Categories
-- Identify categories that frequently appear in daily expenses and analyze their contribution to overall spending.
