# Spark on Kube

## Local with DockerCompose

Set the env variables in `.env`:

### Configs

```ini
MINIO_ROOT_USER=miniouser
MINIO_ROOT_PASSWORD=miniopassword

# EXPOSED PORTS
MINIO_UI_PORT=9001
SPARK_MASTER_UI_PORT=8081
SPARK_WORKER_UI_PORT=8082
```

Configure the Spark master/worker in `spark-docker/spark-defaults.conf`.

### Make

Recipes for the Docker-compose deployment:
- `up`: `docker compose up -d`. **Note**: Make sure to run `make create-jar` to create the fat jar that will end up inside the custom docker image.
- `down`: `docker compose down`
- `submit-job`: Submit a Spark job
- `create-jar`: Create the uber jar for the Spark job

---

## K8S

### ⚠️⚠️Important⚠️⚠️: Do not publish the Helm package <sup>[1]</sup>

The deployment includes an optional minio instance necessary to save input/output of Spark tasks. With `make`:

(Shared with the local configuration)

- `seed-minio`: seed minio with the dataset, spark jar and pod template.

(For the following ones, change Makefile and `cd k8s`)

- `install`: create all the k8s resources for spark. **Note**: if minio needs to be installed, before running a task make sure to run the `seed-minio` recipe.Example:
    ```bash
    make install HELM_VALUES_FILES="./pipeline-demo/local-env-values.yaml" NAMESPACE="spark-k8s" DRY_RUN=true
    ```
- `uninstall`: uninstall the k8s resources for the pipeline, including Spark, Minio (if present) and Airflow
    ```bash
    make uninstall NAMESPACE="spark-k8s"
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

- `setup-airflow`: Create the in-cluster connection for the kubernetes operator for Airflow
    ```bash
    make setup-airflow WORKER_POD_NAME="pipeline-demo-airflow-worker-0"
    ```

- `generate-kube-config`: Generate kube config for kubernetes operator for Airflow. The returned kube config must be manually installed.
    ```bash
    make generate-kube-config TOKEN_SECRET="pipeline-demo-service-account-token-secret" K8S_ENDPOINT="https://localhost:6443"
    ```

### Kube Proxy and traffic capturing

To see K8s internet traffic, follow this procedure:

- Create a Kube Proxy that exposes HTTP port.
    ```bash
    kubectl proxy --api-prefix=/ --port=8083 --address="0.0.0.0" --accept-hosts='^.*$' --accept-paths='^.*$'
    ```

- Run `tcpdump` to start capturing traffic
    ```bash
    tcpdump -i any -w kube_proxy_traffic.pcap port 8083
    ```

- Create a new Kube config and set `KUBECONFIG` env variable with its path (or update the existing one). In the new configuration, the cluster server is `http://you_server_endpoint:8083`.



<sup>[1]</sup> TODO: the package includes all the files that should be excluded from the `.helmignore`. However, excluding them from there, makes them invisible to `.File.Get`. See [this issue](https://github.com/helm/helm/issues/3050).