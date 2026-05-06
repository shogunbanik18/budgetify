# Databricks notebook source
# MAGIC %md Python code to extract the csv files form xlsx file

# COMMAND ----------

# DBTITLE 1,Installing Openpyxl
pip install openpyxl

# COMMAND ----------

# DBTITLE 1,Restarting the Python Kernel
# MAGIC %restart_python

# COMMAND ----------

# DBTITLE 1,Importing Common Env
# MAGIC %run /Workspace/Budgetify/Common_Env

# COMMAND ----------

# DBTITLE 1,Extracting the Sheets from Excel File
import pandas as pd 
import os 

excel_folder_path = EnvironmentConfig().getExcelFilePath()
FileName = EnvironmentConfig().getFileName()
targetfilename = FileName.split('.')[0]
excel_file_path = excel_folder_path + FileName
output_folder = EnvironmentConfig().getOutputFolder()

os.makedirs(output_folder,exist_ok = True)

excel_file = pd.ExcelFile(excel_file_path)
for sheet_name in excel_file.sheet_names:
    df = pd.read_excel(excel_file,sheet_name=sheet_name)
    cleaned_name = sheet_name.lower().strip()
    # print(cleaned_name)
    output_filename = f"{targetfilename}_{cleaned_name}.csv"
    output_path = f"{output_folder}/{output_filename}"
    df.to_csv(output_path, index=False)
    print(f"Created: {output_filename}")

print("All sheets converted successfully!")

# COMMAND ----------


