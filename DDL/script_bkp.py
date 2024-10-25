import pandas as pd
import os
import psycopg2
import util
import json

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
print(os.listdir())

try:
    conn = psycopg2.connect(**connection_parameters)
    curr = conn.cursor()
    print("Connection Established Successfully!!")

    #####
    # schema creation
    schema_name = "finance_insights"
    schema_check_query = f"SELECT schema_name FROM information_schema.schemata WHERE schema_name = '{schema_name}';"
    curr.execute(schema_check_query)
    results = curr.fetchone()
    print(f"Schema check : {results}")

    ##checking if the schema was already present or not
    if results is not None:
        print(f"Schema '{schema_name}' already exists !!")
    else:
        print(f"Schema '{schema_name}' does not exist and hence creating a schema ")
        create_schema_query = f"create schema if not exists {schema_name}"
        curr.execute(create_schema_query)
        conn.commit()
        print(f"Schema '{schema_name}' created successfully!")

    # Configure logging
    print(f"Current working directory is  : {os.getcwd()}")
    try:
        util.set_up_logging()
        util.log_info("This is an info message")
    except Exception as e:
        print(f"Error occurred : {str(e)}")
    #####

    # Iterating in the root directory
    for file_name in os.listdir(root_directory):
        if file_name.endswith(".xlsx"):
            excel_file_path = os.path.join(root_directory, file_name)
            print(excel_file_path)

            xl = pd.ExcelFile(excel_file_path)
            sheet_names = xl.sheet_names
            print(f"sheets found : {sheet_names}")

            ####
            ###iterating in each one of the sheets present in the xlsx file
            for sheets in sheet_names:
                df = pd.read_excel(excel_file_path, sheet_name=sheets)
                df = xl.parse(sheets)
                df.columns = [col.strip().lower() for col in df.columns]

                print(f"Reading Sheet : {sheets}")

                # Checking the sheet naming convention
                table_name = sheets.replace(" ", "_").lower()
                full_table_name = f"{schema_name}.{table_name}"

                ##saving the df to a temporary csv file
                temp_csv_file = f"{table_name}.csv"
                df.to_csv(temp_csv_file, index=False)
                print(f"File has been saved as :{temp_csv_file} ")
    for file_name in os.listdir(root_directory):
        # if file_name.endswith('.csv') :
        if file_name == "july_2024.csv":
            print(f"detected filename as : {file_name}")
            df_csv = pd.read_csv(file_name)
            print(df_csv.head(3))

            target_table_name = os.path.splitext(file_name)[0].replace(" ", "_").lower()
            full_table_name = f"{schema_name}.{target_table_name}"
            print(full_table_name)
            print(target_table_name)

            with open(file_name, "r") as f:
                curr.copy_expert(
                    f"copy {full_table_name} from stdin with csv header delimiter ',' ",
                    f,
                )

            conn.commit()
            print(f"data for {file_name} copied successfully")
#
#
# #                     # Reading the orginal columns from the excel
# #                     # original_columns = xl.parse(sheets, nrows=0).columns.tolist()
# #                     original_columns = [col.lower() for col in xl.parse(sheets, nrows=0).columns]
# #                     print(original_columns)
# #
# #                     ####Loading the data using copy command
# #                     # Prepare the COPY command to load data, using the original column names
# #                     copy_command = f"""
# #                     COPY {full_table_name} ({', '.join(original_columns)})
# #                     FROM '{os.path.abspath(temp_csv_file)}'
# #                     WITH (FORMAT csv, HEADER true)
# #                     """
# #
# #                     print(f'Executing COPY command: {copy_command}')
# #                     curr.execute(copy_command)
# #                     print(f'Executing Successfull for : {copy_command}')
# #                     conn.commit()
# #                     print(f"Data from sheet '{sheets}' loaded successfully!")

except Exception as e:
    print(f"Error occured : {e}")

finally:
    curr.close()
    conn.close()
