SHELL = /bin/bash

# Parameters
# - HELM_VALUES_FILES: space-separated file path of values.yml files to use with `helm install` commands
# - DRY_RUN=true: enable dry run
# - NAMESPACE: namespace where kube resources are created
# - CREATE_NS: create namespace if does not exist yet
# - SPARK_TASK: name of the spark task to run

DRY_RUN_INSTALL_OPTIONS := $(if $(DRY_RUN),--debug --dry-run,)
HELM_VALUES_FILES_OPTIONS := $(foreach file,$(HELM_VALUES_FILES),--values $(file))
CREATE_NS_OPTION := $(if $(CREATE_NS),--create-namespace,)


.PHONY: install uninstall run-spark-task delete-task build-airflow-image setup-airflow

# Parameters \
- HELM_VALUES_FILES: space-separated file path of values.yml files to use with `helm install` commands \
- DRY_RUN=true: enable dry run \
- NAMESPACE: namespace where kube resources are created \
- CREATE_NS: create namespace if does not exist yet
install:
	helm upgrade --install --wait ${DRY_RUN_INSTALL_OPTIONS} ${HELM_VALUES_FILES_OPTIONS} pipeline-demo ./pipeline-demo --namespace="${NAMESPACE}" ${CREATE_NS_OPTION}

# Parameters \
- NAMESPACE: namespace where kube resources have been created
uninstall:
	helm uninstall --wait pipeline-demo --namespace="${NAMESPACE}" || echo "No pipeline-demo release found"
	helm uninstall --wait pipeline-demo-airflow --namespace="${NAMESPACE}" || echo "No airflow release found"
	helm uninstall --wait pipeline-demo-spark-operator --namespace="${NAMESPACE}" || echo "No spark operator release found"
	kubectl delete all,configmap,secret -l app.kubernetes.io/name=pipeline-demo


# Parameters \
- HELM_VALUES_FILES: space-separated file path of values.yml files to use with `helm install` commands \
- DRY_RUN=true: enable dry run \
- NAMESPACE: namespace where kube resources are created \
- CREATE_NS: create namespace if does not exist yet \
- SPARK_TASK: name of the spark task to run
run-spark-task:
	helm upgrade --install ${DRY_RUN_INSTALL_OPTIONS} ${HELM_VALUES_FILES_OPTIONS} spark-task-${SPARK_TASK} ./spark-tasks --namespace="${NAMESPACE}" ${CREATE_NS_OPTION}

# Parameters \
- SPARK_TASK: name of the spark task to run
delete-task:
	helm uninstall spark-task-${SPARK_TASK}
	# garbage collect the driver pod
	kubectl delete pod --selector="createdByServiceAccount=true"

# Parameters \
- IMAGE_TAG: image tag for airflow
build-airflow-image:
	docker build -t ${IMAGE_TAG} ./airflow

# Parameters \
- WORKER_POD_NAME: airflow worker pod name
setup-airflow:
	kubectl exec -it ${WORKER_POD_NAME} -- airflow connections add --conn-json '
		{
			"description": "K8S connections for deploying pods in the same cluster as the Airflow worker pod",
			"conn_type": "kubernetes", 
			"extra": {
				"in_cluster": true
			}
		}' \
		in_cluster_connection