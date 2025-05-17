csv_file_path = os.path.join(root_directory, file_name)
# 
#                 # Read CSV with Pandas and handle NaNs
#                 df_csv = pd.read_csv(csv_file_path, na_values="")
# 
#                 util.log_info(
#                     f"The number of columns in df_csv is : {len(df_csv.columns)}"
#                 )
#                 list_col = []
#                 for c in df_csv.columns:
#                     list_col.append(c)
#                 util.log_info(
#                     f"The list of columns present in the csv files are  : {list_col}"
#                 )
# 
#                 columns_query = f"""
#                 SELECT count(*)
#                 FROM information_schema.columns
#                 WHERE table_schema = '{schema_name}'
#                 AND table_name = '{table_name}';
#                 """
# 
#                 curr.execute(columns_query)
#                 num_columns_pg = curr.fetchone()[0]
# 
#                 util.log_info(
#                     f"Number of columns in PostgreSQL table '{schema_name}.{table_name}': {num_columns_pg}"
#                 )
# 
#                 # Example: util.log_info all column names in the PostgreSQL table
#                 column_names_query = f"SELECT column_name FROM information_schema.columns WHERE table_schema = '{schema_name}' AND table_name = '{table_name}';"
#                 curr.execute(column_names_query)
#                 columns_pg = curr.fetchall()
#                 columns_pg = [col[0] for col in columns_pg]
#                 util.log_info(
#                     f"All columns in PostgreSQL table '{schema_name}.{table_name}': {columns_pg}"
#                 )
# 
#                 df_csv = df_csv.where(pd.notnull(df_csv), None)
# 
#                 fname = file_name.split(".")
#                 target_table_name = fname[0]
#                 full_table_name = f"finance_insights_L0.{target_table_name}"
# 
#                 with open(csv_file_path, "r") as f:
#                     curr.copy_expert(
#                         f"COPY {full_table_name} FROM stdin WITH CSV HEADER DELIMITER ','",
#                         f,
#                     )
# 
#                 conn.commit()
#                 util.log_info(f"Data for {file_name} copied successfully")
# 
#                 # Delete the temporary csv file
#                 os.remove(csv_file_path)
#                 util.log_info(
#                     f"Temporary file {csv_file_path} has been  deleted successfully"
#                 )
#                 util.log_info("########################")