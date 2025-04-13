from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.email import EmailOperator
from airflow.utils.dates import days_ago
from airflow.utils.helpers import chain
from datetime import timedelta


# Dummy Python functions
def start():
    print("Starting the pipeline...")


def process_data():
    print("Processing data...")


def end():
    print("Pipeline finished.")


# Default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

# Define the DAG
with DAG(
    dag_id='dummy_pipeline_example',
    default_args=default_args,
    description='A simple dummy DAG example',
    schedule_interval='@daily',  # Run once a day
    start_date=days_ago(1),
    catchup=False,  # Avoid running DAG for past dates
    tags=['example', 'dummy'],
) as dag:

    start_task = PythonOperator(
        task_id='start_task',
        python_callable=start,
    )

    process_task = PythonOperator(
        task_id='process_data_task',
        python_callable=process_data,
    )

    end_task = PythonOperator(
        task_id='end_task',
        python_callable=end,
    )

    notify_email_task = EmailOperator(
        task_id='send_email_notification',
        to='shogun.banik.jobs.09@gmail.com',
        subject='Airflow DAG Completed: dummy_pipeline_example',
        html_content="""
        <h3>Success!</h3>
        <p>The DAG <b>dummy_pipeline_example</b> has completed successfully.</p>
        """,
    )
    
    chain(start_task, process_task, end_task, notify_email_task)