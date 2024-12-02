import json

import pendulum

from airflow.decorators import dag, task

@dag(
    schedule=None,
    start_date=pendulum.datetime(2024, 1, 1, tz="UTC"),
    catchup=False,
    tags=["example"],
)
def tutorial_taskflow_api():
    """
    Example dag for Spark task
    """
    @task()
    def run_spark_task():
        """
        example Spark task execution
        """
        data_string = '{"1001": 301.27, "1002": 433.21, "1003": 502.22}'

        return json.loads(data_string)
    
    return run_spark_task()

tutorial_taskflow_api()
