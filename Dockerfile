FROM apache/airflow:2.8.1

# Switch to root user to install dependencies
USER root

# Install PostgreSQL development libraries for psycopg2
RUN apt-get update && apt-get install -y \
    postgresql libpq-dev \
    && apt-get clean

# Switch back to airflow user for security reasons
USER airflow

# Copy the requirements.txt into the container
COPY ./external_scripts/requirements.txt /requirements.txt

# Install the Python dependencies from requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt
