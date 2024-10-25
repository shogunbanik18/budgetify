-- finance_insights_wrk.q1_investments source

CREATE OR REPLACE VIEW finance_insights_wrk.q1_investments
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
  WHERE a.financial_category = 'invest'::text AND a.transaction_type = 'investment'::text
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
  WHERE m.financial_category = 'invest'::text AND m.transaction_type = 'investment'::text
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
  WHERE j.financial_category = 'invest'::text AND j.transaction_type = 'investment'::text;