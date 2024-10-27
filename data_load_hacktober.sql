import psycopg2
import sys  # for accessing the command line arguments
import util
import os
import json
import pandas as pd

with open("config.json", "r") as config_file:
    config = json.load(config_file)

# Database connection details
DB_PARAMS = {
    "dbname": config["dbname"],
    "user": config["user"],
    "password": config["password"],
    "host": config["host"],
    "port": config["port"],
}

def table_exists(cursor, schema_name, table_name):
    """Check if a table exists in the specified schema."""
    query = """
    SELECT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = %s
        AND table_name = %s
    );
    """
    cursor.execute(query, (schema_name, table_name))
    return cursor.fetchone()[0]


def drop_table(cursor, schema_name, table_name):
    """Drop a table if it exists."""
    if table_exists(cursor, schema_name, table_name):
        util.log_info(f"Dropping table {schema_name}.{table_name}...")
        cursor.execute(f"DROP TABLE {schema_name}.{table_name};")
        util.log_info(f"Table {schema_name}.{table_name} dropped successfully.")


def create_target_table(cursor, source_table, target_table):
    """Create the target table from the source table."""
    util.log_info(f"Creating target table {target_table} from {source_table}...")
    cursor.execute(
        f"""CREATE TABLE {target_table} AS SELECT
            lower(expense_category) AS expense_category,
            lower(expense_description) AS expense_description,
            COALESCE(expected_budget, 0) AS expected_budget,
            COALESCE(CAST(amount AS INTEGER), 0) AS amount,
            lower(payment_status) AS payment_status,
            COALESCE(lower(payment_mode), 'upi') AS payment_mode,
            lower(financial_category) AS financial_category,
            lower(transaction_type) AS transaction_type,
            COALESCE(record_date, '2024-07-31 00:00:00.000') AS record_date,
            lower(currency) AS currency
        FROM {source_table};"""
    )
    util.log_info(f"Target table {target_table} created successfully.")


def load_data(current_schema, target_schema, table_name):
    """Load data from the current schema to the target schema."""
    util.log_info("#############################")
    try:
        source_table = f"{current_schema}.{table_name}"
        target_table = f"{target_schema}.{table_name}"

        # Extract data from staging layer
        cursor.execute(f"SELECT * FROM {source_table}")
        staging_data = cursor.fetchall()

        # Check if the target table already exists
        drop_table(cursor, target_schema, table_name)

        # Create target table
        create_target_table(cursor, source_table, target_table)

        # Transformation
        # Create a temporary table for file_nm insertion
        temp_table = f"{target_schema}.{table_name}_temp"
        drop_table(cursor, target_schema, f"{table_name}_temp")

        cursor.execute(
            f"CREATE TABLE {temp_table} AS SELECT *, '{table_name}' AS file_nm FROM {target_table};"
        )
        conn.commit()
        util.log_info(f"File_nm insertion successful into {temp_table}.")

        # Dropping the original table and renaming the temp table
        drop_table(cursor, target_schema, table_name)
        cursor.execute(f"ALTER TABLE {temp_table} RENAME TO {table_name};")
        conn.commit()

        util.log_info(f"Changes made successfully for table {table_name}.")

    except Exception as e:
        util.log_error(f"Error in loading data: {str(e)}")
        conn.rollback()


def load_all_tables(current_schema, target_schema):
    """Load all tables from the current schema to the target schema."""
    util.log_info("########### Fetching all tables ###########")
    cursor.execute(
        f"SELECT table_name FROM information_schema.tables WHERE table_schema = '{current_schema}'"
    )
    all_tables = cursor.fetchall()

    util.log_info(f"Batch loading from {current_schema} to {target_schema} in progress!")
    for t1 in all_tables:
        tb = t1[0]
        load_data(current_schema, target_schema, tb)

def handle_views(target_schema):
    """Handle view operations for the finance insights."""
    if target_schema == "finance_insights_wrk":
        util.log_info("Storing the views in a temp layer...")
        cursor.execute("CALL finance_insights_wrk.store_view_definitions();")
        util.log_info("Dropping the views for proper data load to wrk...")
        cursor.execute("CALL finance_insights_wrk.drop_all_views();")


def recreate_views(target_schema):
    """Recreate views after data loading."""
    if target_schema == "finance_insights_wrk":
        util.log_info("Recreating all the views...")
        cursor.execute("CALL finance_insights_wrk.recreate_all_views();")
        conn.commit()


if __name__ == "__main__":
    ### Configure logging
    try:
        util.set_up_logging()
        util.log_info(f"Current working directory is: {os.getcwd()}")
    except Exception as e:
        util.log_error(f"Error occurred: {str(e)}")

    util.log_info("############ Data Loading in Progress ##############")
    
    current_schema = sys.argv[1]
    target_schema = sys.argv[2]

    util.log_info(
        f"Data Integration from {current_schema} to {target_schema} is in progress"
    )

    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cursor = conn.cursor()

        handle_views(target_schema)  # Handle views if needed
        load_all_tables(current_schema, target_schema)  # Load all tables
        util.log_info("Loading Successful!")

        recreate_views(target_schema)  # Recreate views if needed

    except Exception as e:
        util.log_error(f"Exception found: {str(e)}")
        print("An error occurred during processing.")
    finally:
        cursor.close()
        conn.close()
