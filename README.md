# Spark on Kube

## Local with DockerCompose

Create a `makefile-includes` directory containing the `Makefile`s with the variables specific to the environment, for example:

```makefile
# local.mk

# Minio
MINIO_ENDPOINT := localhost
MINIO_ROOT_USER := miniouser
MINIO_ROOT_PASSWORD := miniopassword
MINIO_UI_PORT := 9001

# Spark
SPARK_MASTER_UI_PORT := 8081
SPARK_WORKER_UI_PORT := 8082
```

Any `prod.*.mk` file in this folder is excluded from git. Then run `make up` to run the `docker compose up`.

Configure the Spark master/worker in `spark-docker/spark-defaults.conf`.

## Make

There are 2 `Makefiles`:
- one for generic recipees (in the root folder) 
- one for Kubernetes-specific recipees (in `k8s` folder)

As for the first one, **make sure to assign the `MAKE_CFG_PATH` variable** to the path of the `Makefile` containing the variables (defaults to `makefile-includes/local.mk`).
The generic `Makefile` recipees are:

- `up`: `docker compose up -d`. **Note**: run `make create-extra-deps-jar` first
- `down`: `docker compose down`
- `submit-job`: Submit a Spark job
- `create-extra-deps-jar`: create the fat jar that will end up inside the custom docker image for spark
- `create-task-jar`: Create the uber jar for each Spark job
- `build-spark-image`: create a custom Docker image for Spark
- `upload-to-minio`: upload a file to the minio instance

---

## K8S

### ⚠️⚠️Important⚠️⚠️: Do not publish the Helm package <sup>[1]</sup>

The deployment includes an optional minio instance necessary to save input/output of Spark tasks. If Minio has not been seeded, first run:

```bash
make seed-minio MINIO_ENDPOINT=...
```

Then all the other `make` recipees are placed in `k8s/Makefile`. Before running them, you can create a custom Makefile that is executed before
the main one and can contain various configurations like k8s namespace, helm release name, etc. Its path can be specified using the variable `MAKE_CFG_PATH`. If empty, then:
1. Make firstly retrieves the current K8s `CONTEXT_NAME` (`kubectl config current-context`)
2. `-include` the Makefile in `k8s/makefile-includes/$CONTEXT_NAME`

Here are some examples of `make` commands:

- `install`: create all the k8s resources for spark. **Note**: if minio needs to be installed, before running a task make sure to run the `seed-minio` recipe.Example:
    ```bash
    make install HELM_VALUES_FILES="./pipeline-demo/local-env-values.yaml" DRY_RUN=true
    ```
- `uninstall`: uninstall the k8s resources for the pipeline
    ```bash
    make uninstall
    ```
- `run-spark-task`: run a Job for the specified Spark task. Example:
    ```bash
    make run-spark-task \
        HELM_VALUES_FILES="./run-spark-task/base-values.yaml ./run-spark-task/local-env-values.yaml ./run-spark-task/task-values/local-sample.yaml" \
        SPARK_TASK="sample" DRY_RUN=true
    ```
- `delete-task`: remove a task and garbage collect the driver pods. Example:
    ```bash
    make delete-task SPARK_TASK="sample"
    ```

- `add-in-cluster-conn-airflow`: Create the in-cluster connection for the kubernetes operator for Airflow
    ```bash
    make add-in-cluster-conn-airflow
    ```

- `generate-kube-config`: Generate kube config of current context for Airflow kubernetes operator. The returned kube config must be manually installed.
    ```bash
    make generate-kube-config
    ```

- `airflow-ui`: port-forward the airflow pod ui port on localhost
    ```bash
    make airflow-ui
    ```

- `prometheus-ui`: port-forward the prometheus pod ui port on localhost
    ```bash
    make prometheus-ui
    ```

---

## Troubleshooting

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

### Debug Spark Pod

Create a debug pod using `kubectl debug`:

```bash
kubectl debug $SPARK_POD --copy-to=debug-pod -it --container=spark-kubernetes-driver -- /bin/bash
```

In the example above, the debug pod recreates a copy of the `spark-kubernetes-driver` container.