from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.operators.email import EmailOperator
from airflow.utils.dates import days_ago
from airflow.utils.helpers import chain
from datetime import timedelta
from datetime import datetime
import pytz  # Import pytz to handle time zones

default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

start_date = datetime(2025, 4, 19, 13, 50, tzinfo=pytz.UTC)   # This is 8:45 AM UTC on April 18th, 2025

# Define the DAG
with DAG(
    dag_id='FY_Monthly_dag',
    default_args=default_args,
    description='A simple dummy DAG example',
    schedule_interval='0 0 15,28 * *',
    start_date=start_date, 
    catchup=False,
    tags=['example', 'bash'],
) as dag:

    start_task = BashOperator(
        task_id='start_task',
        bash_command='echo "Starting the pipeline..."'
    )

    Excel_to_L0_Load = BashOperator(
        task_id='Excel_to_L0_Load',
        bash_command='python /opt/airflow/external_scripts/script.py',
    )

    L0_TO_L1_Load = BashOperator(
        task_id='L0_TO_L1_Load',
        bash_command='python /opt/airflow/external_scripts/data_load.py finance_insights_l0 finance_insights_l1',
    )

    L1_TO_L2_Load = BashOperator(
        task_id='L1_TO_L2_Load',
        bash_command='python /opt/airflow/external_scripts/data_load.py finance_insights_l1 finance_insights_l2',
    )

    L2_TO_Reports_April = BashOperator(
        task_id='L2_TO_Reports_April',
        bash_command='python /opt/airflow/external_scripts/Generate_insights.py --month april --year 2025',
    )

    L2_TO_Reports_May = BashOperator(
        task_id='L2_TO_Reports_May',
        bash_command='python /opt/airflow/external_scripts/Generate_insights.py --month may --year 2025',
    )

    L2_TO_Reports_June = BashOperator(
        task_id='L2_TO_Reports_June',
        bash_command='python /opt/airflow/external_scripts/Generate_insights.py --month june --year 2025',
    )

    L2_TO_Reports_July = BashOperator(
        task_id='L2_TO_Reports_July',
        bash_command='python /opt/airflow/external_scripts/Generate_insights.py --month july --year 2025',
    )

    L2_TO_Reports_August = BashOperator(
    task_id='L2_TO_Reports_August',
    bash_command='python /opt/airflow/external_scripts/Generate_insights.py --month august --year 2025',
    )

    L2_TO_Reports_September = BashOperator(
        task_id='L2_TO_Reports_September',
        bash_command='python /opt/airflow/external_scripts/Generate_insights.py --month september --year 2025',
    )

    L2_TO_Reports_October = BashOperator(
        task_id='L2_TO_Reports_October',
        bash_command='python /opt/airflow/external_scripts/Generate_insights.py --month october --year 2025',
    )

    L2_TO_Reports_November = BashOperator(
        task_id='L2_TO_Reports_November',
        bash_command='python /opt/airflow/external_scripts/Generate_insights.py --month november --year 2025',
    )

    L2_TO_Reports_December = BashOperator(
        task_id='L2_TO_Reports_December',
        bash_command='python /opt/airflow/external_scripts/Generate_insights.py --month december --year 2025',
    )

    L2_TO_Reports_January = BashOperator(
        task_id='L2_TO_Reports_January',
        bash_command='python /opt/airflow/external_scripts/Generate_insights.py --month january --year 2026',
    )

    L2_TO_Reports_February = BashOperator(
        task_id='L2_TO_Reports_February',
        bash_command='python /opt/airflow/external_scripts/Generate_insights.py --month february --year 2026',
    )

    L2_TO_Reports_March = BashOperator(
        task_id='L2_TO_Reports_March',
        bash_command='python /opt/airflow/external_scripts/Generate_insights.py --month march --year 2026',
    )

    Reports_Task = [
    L2_TO_Reports_April,
    L2_TO_Reports_May,
    L2_TO_Reports_June,
    L2_TO_Reports_July,
    L2_TO_Reports_August,
    L2_TO_Reports_September,
    L2_TO_Reports_October,
    L2_TO_Reports_November,
    L2_TO_Reports_December,
    L2_TO_Reports_January,
    L2_TO_Reports_February,
    L2_TO_Reports_March
    ]

    task_list = [Excel_to_L0_Load,L0_TO_L1_Load,L1_TO_L2_Load] 

    wait_task = BashOperator(
    task_id='wait_before_reports',
    bash_command='sleep 60',
    )

    end_task = BashOperator(
        task_id='end_task',
        bash_command='echo "Ending the pipeline..."'
    )

    # send_email = BashOperator(
    # task_id='send_email',
    # bash_command='python /opt/airflow/external_scripts/send_mail.py'
    # )


    # notify_email_task = EmailOperator(
    #     task_id='send_email_notification',
    #     to='shogun.banik.jobs.09@gmail.com',
    #     subject='Airflow DAG Completed: FY_Monthly_dag',
    #     html_content=""" 
    #     <h3>Success!</h3>
    #     <p>The DAG <b>FY_Monthly_dag</b> has completed successfully.</p>
    #     """,
    # )

    # chain(start_task,*task_list,end_task)

    chain(start_task, *task_list)
    chain(*task_list, wait_task)           # Add the wait here
    chain(wait_task, Reports_Task)         # Reports start after wait finishes
    chain(Reports_Task, end_task)
