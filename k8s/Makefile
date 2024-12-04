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


.PHONY: install run-spark-task delete-task
	
install:
	helm upgrade --install --wait ${DRY_RUN_INSTALL_OPTIONS} ${HELM_VALUES_FILES_OPTIONS} pipeline-demo ./pipeline-demo --namespace="${NAMESPACE}" ${CREATE_NS_OPTION}

uninstall:
	helm uninstall pipeline-demo --namespace="${NAMESPACE}" || echo "No pipeline-demo release found"
	helm uninstall pipeline-demo-airflow --namespace="${NAMESPACE}" || echo "No airflow release found"
	kubectl delete job -l "app.kubernetes.io/part-of=airflow,app.kubernetes.io/component=install-job"
	kubectl delete job -l "app.kubernetes.io/part-of=spark,app.kubernetes.io/component=upload-spark-pod-template-job"

run-spark-task:
	helm upgrade --install ${DRY_RUN_INSTALL_OPTIONS} ${HELM_VALUES_FILES_OPTIONS} spark-task-${SPARK_TASK} ./spark-tasks --namespace="${NAMESPACE}" ${CREATE_NS_OPTION}

delete-task:
	helm uninstall spark-task-${SPARK_TASK}
	# garbage collect the driver pod
	kubectl delete pod --selector="createdBySparkServiceAccount=true"
