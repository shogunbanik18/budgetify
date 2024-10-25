-- finance_insights_wrk.q1_expenses source

CREATE OR REPLACE VIEW finance_insights_wrk.q1_expenses
AS SELECT a.expense_category,
    a.expense_description,
    a.expected_budget,
    a.amount,
    a.payment_status,
    a.payment_mode,
    a.financial_category,
    a.transaction_type,
    a.record_date,
    a.currency,
    a.file_nm
   FROM finance_insights_wrk.april_2024 a
  WHERE a.transaction_type = 'expense'::text AND a.amount <> 0
UNION
 SELECT m.expense_category,
    m.expense_description,
    m.expected_budget,
    m.amount,
    m.payment_status,
    m.payment_mode,
    m.financial_category,
    m.transaction_type,
    m.record_date,
    m.currency,
    m.file_nm
   FROM finance_insights_wrk.may_2024 m
  WHERE m.transaction_type = 'expense'::text AND m.amount <> 0::double precision
UNION
 SELECT j.expense_category,
    j.expense_description,
    j.expected_budget,
    j.amount,
    j.payment_status,
    j.payment_mode,
    j.financial_category,
    j.transaction_type,
    j.record_date,
    j.currency,
    j.file_nm
   FROM finance_insights_wrk.june_2024 j
  WHERE j.transaction_type = 'expense'::text AND j.amount <> 0::double precision;