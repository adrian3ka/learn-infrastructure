```
docker rm airflow

docker run -it --name=airflow -p 8080:8080 puckel/docker-airflow:1.10.9 webserver

export AIRFLOW_CONTAINER_ID=$(docker ps -aqf "name=airflow")

docker exec -it $AIRFLOW_CONTAINER_ID bash

mkdir /usr/local/airflow/dags

exit
```
Please open localhost:8080 and you could see the airflow admin page


You can create and run your first task with:

```
docker cp Helloworld.py $AIRFLOW_CONTAINER_ID:/usr/local/airflow/dags/Helloworld.py

docker exec -it $AIRFLOW_CONTAINER_ID bash

airflow list_dags

airflow test Helloworld task_1 2020-08-04
```

Now after waiting some minutes you could see the Helloworld DAG in the admin board and trigger it from there
