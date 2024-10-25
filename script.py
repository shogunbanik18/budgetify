import pandas as pd
import os
import psycopg2  # type: ignore
import util
import importlib
import json

importlib.reload(util)

if __name__ == "__main__":
    target_directory = (
        r"C:\Users\shogu\OneDrive\Desktop\Data Engineering\FY_Data_analysis"
    )
    os.chdir(target_directory)

    ### Configure logging
    try:
        util.clear_logs()
        util.set_up_logging()
        util.log_info(f"Current working directory is: {os.getcwd()}")
    except Exception as e:
        util.log_info(f"Error occurred : {str(e)}")
    util.log_info(f"Available functions in util: {dir(util)}")

    with open("config.json", "r") as config_file:
        config = json.load(config_file)

    # creating the connection parameters
    connection_parameters = {
        "dbname": config["dbname"],
        "user": config["user"],
        "password": config["password"],
        "host": config["host"],
        "port": config["port"],
    }

    root_directory = "C:/Users/shogu/OneDrive/Desktop/Data Engineering/FY_Data_analysis"
    util.log_info(f"{os.listdir()}")

    try:
        conn = psycopg2.connect(**connection_parameters)
        curr = conn.cursor()
        util.log_info("Connection Established Successfully!!")

        #####
        # schema creation
        schema_name = "finance_insights_stg"
        schema_check_query = f"SELECT schema_name FROM information_schema.schemata WHERE schema_name = '{schema_name}';"
        curr.execute(schema_check_query)
        results = curr.fetchone()
        util.log_info(f"Schema Check : {results}")

        ##checking if the schema was already present or not
        if results is not None:
            util.log_info(f"Schema '{schema_name}' already exists !!")
        else:
            util.log_info(
                f"Schema '{schema_name}' does not exists and Hence creating a new Schema !!"
            )
            create_schema_query = f"create schema if not exists {schema_name}"
            curr.execute(create_schema_query)
            conn.commit()
            util.log_info(f"{schema_name}' created successfully!")

        # Iterating in the root directory
        for file_name in os.listdir(root_directory):
            if file_name.endswith(".xlsx") and file_name == "Mock_data_fy_24_25.xlsx":
                # if file_name.endswith(".xlsx") and file_name == "FY_2024_25.xlsx":
                excel_file_path = os.path.join(root_directory, file_name)
                util.log_info(excel_file_path)

                xl = pd.ExcelFile(excel_file_path)
                sheet_names = xl.sheet_names
                util.log_info(f"sheets found : {sheet_names}")

                ###iterating in each one of the sheets present in the xlsx file
                for sheets in sheet_names:
                    df = pd.read_excel(excel_file_path, sheet_name=sheets)
                    df = xl.parse(sheets)
                    df.columns = [col.strip().lower() for col in df.columns]

                    util.log_info(f"Reading Sheet : {sheets}")

                    # Checking the sheet naming convention
                    table_name = sheets.replace(" ", "_").lower()
                    full_table_name = f"{schema_name}.{table_name}"

                    # Converting the record_date column to the correct format
                    if "record_date" in df.columns:
                        df["record_date"] = pd.to_datetime(
                            df["record_date"], format="%d.%m.%Y"
                        ).dt.strftime("%Y-%m-%d")

                    ##saving the df to a temporary csv file
                    temp_csv_file = f"{table_name}.csv"
                    df.to_csv(temp_csv_file, index=False)
                    util.log_info(f"File has been saved as :{temp_csv_file} ")

                    # Check if the table exists before dropping it
                    table_exists_query = f"""
                    SELECT EXISTS (
                        SELECT 1
                        FROM information_schema.tables
                        WHERE table_schema = '{schema_name}'
                        AND table_name = '{table_name}'
                    );
                    """
                    curr.execute(table_exists_query)
                    table_exists = curr.fetchone()[0]

                    # If the table exists executing drop ddl query
                    if table_exists:
                        drop_ddl_query = f"DROP TABLE {full_table_name};"
                        curr.execute(drop_ddl_query)
                        conn.commit()
                        util.log_info(f"Executing Drop DDL query: {drop_ddl_query}")

                    # Dynamic ddl creation
                    ddl_query = f"CREATE TABLE IF NOT EXISTS {full_table_name} ("
                    column_definitions = []
                    for col in df.columns:
                        if col == "record_date":
                            column_type = "TIMESTAMP"
                        elif pd.api.types.is_integer_dtype(df[col]):
                            column_type = "INTEGER"
                        elif pd.api.types.is_float_dtype(df[col]):
                            column_type = "FLOAT"
                        elif pd.api.types.is_datetime64_any_dtype(df[col]):
                            column_type = "TIMESTAMP"
                        else:
                            column_type = "VARCHAR(200)"
                        column_definitions.append(f"{col} {column_type}")

                    util.log_info(f"Columsdef are {column_definitions}")
                    ddl_query += ", ".join(column_definitions) + ");"
                    util.log_info(f"Creating table with query: {ddl_query}")
                    curr.execute(ddl_query)
                    conn.commit()
                    util.log_info(f"DDL of Table {table_name} Created Successfully!!")
                    util.log_info("#########################")

        # testing
        for file_name in os.listdir(root_directory):
            if file_name.endswith(".csv") and file_name != "Data_Dictionary.csv":

                csv_file_path = os.path.join(root_directory, file_name)

                # Read CSV with Pandas and handle NaNs
                df_csv = pd.read_csv(csv_file_path, na_values="")

                util.log_info(
                    f"The number of columns in df_csv is : {len(df_csv.columns)}"
                )
                list_col = []
                for c in df_csv.columns:
                    list_col.append(c)
                util.log_info(
                    f"The list of columns present in the csv files are  : {list_col}"
                )

                columns_query = f"""
                SELECT count(*)
                FROM information_schema.columns
                WHERE table_schema = '{schema_name}'
                AND table_name = '{table_name}';
                """

                curr.execute(columns_query)
                num_columns_pg = curr.fetchone()[0]

                util.log_info(
                    f"Number of columns in PostgreSQL table '{schema_name}.{table_name}': {num_columns_pg}"
                )

                # Example: util.log_info all column names in the PostgreSQL table
                column_names_query = f"SELECT column_name FROM information_schema.columns WHERE table_schema = '{schema_name}' AND table_name = '{table_name}';"
                curr.execute(column_names_query)
                columns_pg = curr.fetchall()
                columns_pg = [col[0] for col in columns_pg]
                util.log_info(
                    f"All columns in PostgreSQL table '{schema_name}.{table_name}': {columns_pg}"
                )

                df_csv = df_csv.where(pd.notnull(df_csv), None)

                fname = file_name.split(".")
                target_table_name = fname[0]
                full_table_name = f"finance_insights_stg.{target_table_name}"

                with open(csv_file_path, "r") as f:
                    curr.copy_expert(
                        f"COPY {full_table_name} FROM stdin WITH CSV HEADER DELIMITER ','",
                        f,
                    )

                conn.commit()
                util.log_info(f"Data for {file_name} copied successfully")

                # Delete the temporary csv file
                os.remove(csv_file_path)
                util.log_info(
                    f"Temporary file {csv_file_path} has been  deleted successfully"
                )
                util.log_info("########################")

    except Exception as e:
        util.log_info(f"Error occured : {e}")

    finally:
        curr.close()
        conn.close()
