import logging
import os
import pandas as pd


def set_up_logging():
    try:
        log_file = os.path.join(os.getcwd(), "app.logs")
        logging.basicConfig(
            filename=log_file,
            level=logging.DEBUG,
            format="%(asctime)s - %(levelname)s - %(message)s",
        )
        print(f"#### Logging set up. Logs will be written to {log_file}.")
    except Exception as e:
        print(f"Error occurred : {str(e)}")


def log_info(msg):
    logging.info(msg)


def clear_logs():
    try:
        log_file = os.path.join(os.getcwd(), "app.logs")
        with open(log_file, "w"):
            pass
        print(
            f"#### Log file {log_file} cleared successfully. Now new logs can be created !!"
        )

    except Exception as e:
        print(f"Error occured while clearing the logs: {str(e)}")


# if __name__ == "__main__":
#     set_up_logging()
#     log_info("Logging set up complete!!")
