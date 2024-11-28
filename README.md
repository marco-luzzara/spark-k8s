# Spark on Kube

## Configuration

Set the env variables in `.env`:

```ini
MINIO_ROOT_USER=miniouser
MINIO_ROOT_PASSWORD=miniopassword

# EXPOSED PORTS
MINIO_UI_PORT=9001
SPARK_MASTER_UI_PORT=8081
SPARK_WORKER_UI_PORT=8082
```

Configure the Spark master/worker in `spark-docker/spark-defaults.conf`.

### Kubernetes

If you deploy it on Minikube, make sure to enable the `csi-hostpath-driver` addon.

```bash
minikube addons enable csi-hostpath-driver
```

---

## `Make` commands

Recipes for the Docker-compose deployment:
- `up`: `docker compose up -d`. **Note**: Make sure to run `make create-jar` to create the fat jar that will end up inside the custom docker image.
- `down`: `docker compose down`
- `submit-job`: Submit a Spark job
- `create-jar`: Create the uber jar for the Spark job

Recipes for the K8s deployment:

- `seed-minio`: seed minio with the dataset, spark jar and pod template.

(For the following ones, first `cd k8s`)

- `install-spark-setup`: create all the k8s resources for spark. **Note**: if minio needs to be installed, before running a task make sure to run the `seed-minio` recipe.Example:
    ```bash
    make install-spark-setup HELM_VALUES_FILES="./spark-setup/local-env-values.yaml" NAMESPACE="spark-k8s" DRY_RUN=true
    ```
- `run-spark-task`: run a Job for the specified Spark task. Example:
    ```bash
    make run-spark-task HELM_VALUES_FILES="./spark-tasks/base-values.yaml ./spark-tasks/local-env-values.yaml ./spark-tasks/task-values/local-sample.yaml" \
        NAMESPACE="spark-k8s" SPARK_TASK="sample" DRY_RUN=true
    ```
- `delete-task`: remove a task and garbage collect the driver pods. Example:
    ```bash
    make delete-task NAMESPACE="spark-k8s" SPARK_TASK="sample"
    ```
