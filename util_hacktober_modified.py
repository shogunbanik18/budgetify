import logging
import os
import pandas as pd


def set_up_logging(log_file_name="app.logs"):
    """Set up logging configuration."""
    try:
        log_file = os.path.join(os.getcwd(), log_file_name)
        logging.basicConfig(
            filename=log_file,
            level=logging.DEBUG,
            format="%(asctime)s - %(levelname)s - %(message)s",
        )
        # Also log to console
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging.INFO)
        formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
        console_handler.setFormatter(formatter)
        logging.getLogger().addHandler(console_handler)
        print(f"#### Logging set up. Logs will be written to {log_file}.")
    except Exception as e:
        print(f"Error occurred while setting up logging: {str(e)}")


def log_info(msg):
    """Log an informational message."""
    logging.info(msg)


def log_error(msg):
    """Log an error message."""
    logging.error(msg)


def log_warning(msg):
    """Log a warning message."""
    logging.warning(msg)


def log_debug(msg):
    """Log a debug message."""
    logging.debug(msg)


def clear_logs(log_file_name="app.logs"):
    """Clear the log file."""
    try:
        log_file = os.path.join(os.getcwd(), log_file_name)
        with open(log_file, "w"):
            pass
        print(
            f"#### Log file {log_file} cleared successfully. Now new logs can be created!"
        )
    except Exception as e:
        print(f"Error occurred while clearing the logs: {str(e)}")


def read_last_n_logs(n=10, log_file_name="app.logs"):
    """Read the last n lines from the log file."""
    try:
        log_file = os.path.join(os.getcwd(), log_file_name)
        with open(log_file, "r") as file:
            lines = file.readlines()
        return lines[-n:] if len(lines) >= n else lines
    except Exception as e:
        print(f"Error occurred while reading logs: {str(e)}")
        return []


def log_dataframe_info(df, msg):
    """Log DataFrame information including shape and columns."""
    if df is not None:
        logging.info(f"{msg} - Shape: {df.shape}, Columns: {list(df.columns)}")
    else:
        logging.warning(f"{msg} - DataFrame is None.")


def log_query_execution(query):
    """Log SQL query execution."""
    logging.info(f"Executing SQL Query: {query}")


if __name__ == "__main__":
    set_up_logging()
    log_info("Logging set up complete!!")
