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
- `start-cluster`: create all the k8s resources. **Note**: Before running the K8s Job with spark, make sure to run the `seed-minio` recipe.
- `seed-minio`: seed minio with the dataset, spark jar and pod template.
- `run-job`: run a sample spark task on k8s
- `delete-job`: delete the job that triggered the spark task. **Note**: it does not delete the driver and executor pods.
- `get-k8s-job-logs`: get the spark task logs