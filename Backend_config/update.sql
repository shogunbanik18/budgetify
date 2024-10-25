-- DROP PROCEDURE finance_insights_wrk.update_wrk_layer_view();

CREATE OR REPLACE PROCEDURE finance_insights_wrk.update_wrk_layer_view()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    BEGIN
        -- Execute the CREATE OR REPLACE VIEW statement using dynamic SQL
        EXECUTE '
        CREATE OR REPLACE VIEW finance_insights_wrk.q2_investments AS
        SELECT 
            j.expense_category,
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
        FROM finance_insights_wrk.july_2024 j
        WHERE j.financial_category = ''invest'' AND j.transaction_type = ''investment''
        
        UNION
        
        SELECT 
            a.expense_category,
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
        FROM finance_insights_wrk.august_2024 a
        WHERE a.financial_category = ''invest'' AND a.transaction_type = ''investment'';
        ';
        
        -- Raise a notice if the view is created successfully
        RAISE NOTICE 'View q2_investments created or replaced successfully.';
    
    EXCEPTION
        WHEN OTHERS THEN
            -- Print out the error message
            RAISE NOTICE 'An error occurred: %', SQLERRM;
    END;
END;
$procedure$
;
