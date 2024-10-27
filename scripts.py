def create_schema(curr, schema_name):
    schema_check_query = f"SELECT schema_name FROM information_schema.schemata WHERE schema_name = '{schema_name}';"
    curr.execute(schema_check_query)
    if curr.fetchone() is None:
        curr.execute(f"CREATE SCHEMA IF NOT EXISTS {schema_name};")
        util.log_info(f"{schema_name} created successfully!")


def process_excel_file(curr, excel_file_path, schema_name):
    xl = pd.ExcelFile(excel_file_path)
    for sheet in xl.sheet_names:
        df = xl.parse(sheet)
        # Perform transformations and save to PostgreSQL...
