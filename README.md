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

---

## `Make` commands

- `up`: `docker compose up -d`. **Note**: Make sure to run `make create-jar` to create the fat jar that will end up inside the custom docker image.
- `down`: `docker compose down`
- `submit-job`: Submit a Spark job
- `create-jar`: Create the uber jar for the Spark job