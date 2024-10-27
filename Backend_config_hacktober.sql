-- DROP PROCEDURE finance_insights_wrk.update_wrk_layer_view();

CREATE OR REPLACE PROCEDURE finance_insights_wrk.update_wrk_layer_view()
LANGUAGE plpgsql
AS $procedure$
DECLARE
    month_list TEXT[] := ARRAY['july_2024', 'august_2024', 'september_2024'];
    sql_statement TEXT;
BEGIN
    -- Start Logging
    RAISE NOTICE 'Starting the view update process for q2_investments at %', clock_timestamp();

    -- Construct the SQL statement dynamically
    sql_statement := '
    CREATE OR REPLACE VIEW finance_insights_wrk.q2_investments AS ';

    FOR i IN ARRAY_LOWER(month_list, 1) .. ARRAY_UPPER(month_list, 1) LOOP
        sql_statement := sql_statement || '
            SELECT 
                ' || month_list[i] || '.expense_category,
                ' || month_list[i] || '.expense_description,
                ' || month_list[i] || '.expected_budget,
                ' || month_list[i] || '.amount,
                ' || month_list[i] || '.payment_status,
                ' || month_list[i] || '.payment_mode,
                ' || month_list[i] || '.financial_category,
                ' || month_list[i] || '.transaction_type,
                ' || month_list[i] || '.record_date,
                ' || month_list[i] || '.currency,
                ' || month_list[i] || '.file_nm
            FROM finance_insights_wrk.' || month_list[i] || '
            WHERE financial_category = ''invest'' AND transaction_type = ''investment''';

        -- Add UNION for all months except the last one
        IF i < ARRAY_UPPER(month_list, 1) THEN
            sql_statement := sql_statement || ' UNION ';
        END IF;
    END LOOP;

    -- Execute the CREATE OR REPLACE VIEW statement using dynamic SQL
    EXECUTE sql_statement;

    -- Log success message
    RAISE NOTICE 'View q2_investments created or replaced successfully at %', clock_timestamp();

    -- Refresh the view
    PERFORM pg_catalog.pg_sleep(0.5); -- Add slight delay for refresh to complete
    RAISE NOTICE 'Refreshing view q2_investments...';
    EXECUTE 'REFRESH MATERIALIZED VIEW finance_insights_wrk.q2_investments';

    -- Log completion message
    RAISE NOTICE 'View q2_investments refreshed successfully at %', clock_timestamp();

EXCEPTION
    WHEN OTHERS THEN
        -- Log and rollback if an error occurs
        RAISE NOTICE 'An error occurred during view update: %', SQLERRM;
        ROLLBACK;
END;
$procedure$;
