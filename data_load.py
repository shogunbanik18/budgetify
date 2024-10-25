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


def load_data(current_schema, target_schema, table_name):
    util.log_info("#############################")
    try:
        source_table = f"{current_schema}.{table_name}"
        target_table = f"{target_schema}.{table_name}"

        # Extract data from staging layer
        cursor.execute(f"SELECT * FROM {source_table}")
        staging_data = cursor.fetchall()

        # need to check if the target table already exists or not
        util.log_info("Checking if the target table already exists : ")
        table_results = table_exists(cursor, target_schema, table_name)
        if table_results:
            util.log_info(f"Table {target_table} already exists !! ")
            util.log_info("Dropping off the table")
            cursor.execute(f"drop table {target_table};")

        # loading the data to the target table
        util.log_info(f"Creating ddl for {target_table}")
        cursor.execute(
            f"""create table if not exists {target_table} as SELECT
                lower(expense_category) AS expense_category,
                lower(expense_description) AS expense_description,
                COALESCE(expected_budget, 0) AS expected_budget,
                COALESCE(CAST(amount AS INTEGER), 0) AS amount,
                lower(payment_status) AS payment_status,
                COALESCE(lower(payment_mode),'upi') AS payment_mode,
                lower(financial_category) AS financial_category,
                lower(transaction_type) AS transaction_type,
                COALESCE(record_date, '2024-07-31 00:00:00.000') AS record_date,
                lower(currency) AS currency
            FROM {source_table};"""
        )
        conn.commit()
        util.log_info(f"Target table : {target_table} created successfully !!")

        cursor.execute(f"SELECT * FROM {target_table}")
        target_data = cursor.fetchall()

        util.log_info(
            f"Data copied from {source_table} to {target_table} successful!!!"
        )

        ##Transformation
        # creating temporary table with file_nm column added there
        # check if temporary table already exists or not
        util.log_info(f"Temp table for file_nm insertion")
        temp_table = f"{target_schema}.{table_name}_temp"

        util.log_info("Checking if the temp target table already exists : ")
        tb1 = f"{table_name}_temp".lower()
        table_results_temp = table_exists(cursor, target_schema, tb1)
        if table_results_temp:
            util.log_info(f"Table {temp_table} already exists !! ")
            util.log_info("Dropping off the table")
            cursor.execute(f"drop table {temp_table};")

        cursor.execute(
            f"create table {temp_table} as select *,'{table_name}' as file_nm from {target_table}"
        )
        conn.commit()
        util.log_info(f"file_nm insertion successfull")

        ##Dropping the original table
        cursor.execute(f"Drop table {target_table};")
        conn.commit()
        ## Altering the temp table to target table name
        cursor.execute(f"alter table {temp_table} rename to {table_name};")
        conn.commit()

        # res = cursor.fetchall()
        util.log_info(f"Changes made successfully!!")

    except Exception as e:
        print(f"Error is {e}")
        conn.rollback()


if __name__ == "__main__":
    print(sys.argv)

    ### Configure logging
    try:
        util.set_up_logging()
        util.log_info(f"Current working directory is: {os.getcwd()}")
    except Exception as e:
        util.log_info(f"Error occurred : {str(e)}")

    util.log_info("###############")
    util.log_info("############ Data Loding in Progress ##############")
    file_path = sys.argv[0]
    current_schema = sys.argv[1]
    target_schema = sys.argv[2]
    # table_name = sys.argv[3]

    util.log_info(
        f"Data Integration from {current_schema} to {target_schema} is in progress"
    )

    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cursor = conn.cursor()

        ## Batch Loading
        ## checking for all the tables in the current schema
        util.log_info("###########all tables")
        cursor.execute(
            f"select table_name from information_schema.tables where table_schema = '{current_schema}'"
        )
        all_tables = cursor.fetchall()

        util.log_info(
            f"######Batch loading from {current_schema} to {target_schema} in Progress !!"
        )
        util.log_info(
            f"Fetching all the tables from current schema  : { current_schema} "
        )
        util.log_info(f"{all_tables}")

        if target_schema == "finance_insights_wrk":
            util.log_info("Storing the views in a temp layer ")
            cursor.execute("call finance_insights_wrk.store_view_definitions();")
            util.log_info("Droping the views for proper data load to wrk ")
            cursor.execute("call finance_insights_wrk.drop_all_views();")

        for t1 in all_tables:
            tb = t1[0]
            load_data(current_schema, target_schema, tb)

        print("Loading Successfull!!")

        if target_schema == "finance_insights_wrk":
            util.log_info("Recreating all the views !!")
            cursor.execute("call finance_insights_wrk.recreate_all_views();")
            conn.commit()

        #######
        # For Single table load Process
        # load_data(current_schema, target_schema, table_name)
    except Exception as e:
        print("Exception found!!")


############
# Command Line Arguments sample for running Master_Integration.py
# python Master_integration.py finance_insights_stg finance_insights_int july_2024
