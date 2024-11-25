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


.PHONY: install-minio-setup install-spark-setup run-spark-task delete-task

install-minio-setup:
	helm upgrade --install ${DRY_RUN_INSTALL_OPTIONS} ${HELM_VALUES_FILES_OPTIONS} minio-setup ./minio-setup --namespace="${NAMESPACE}" ${CREATE_NS_OPTION}
	
install-spark-setup:
	helm upgrade --install ${DRY_RUN_INSTALL_OPTIONS} ${HELM_VALUES_FILES_OPTIONS} spark-setup ./spark-setup --namespace="${NAMESPACE}" ${CREATE_NS_OPTION}

run-spark-task:
	helm upgrade --install ${DRY_RUN_INSTALL_OPTIONS} ${HELM_VALUES_FILES_OPTIONS} spark-task-${SPARK_TASK} ./spark-tasks --namespace="${NAMESPACE}" ${CREATE_NS_OPTION}

delete-task:
	helm uninstall spark-task-${SPARK_TASK}
	# garbage collect the driver pod
	kubectl delete pod --selector="createdBySparkServiceAccount=true"
