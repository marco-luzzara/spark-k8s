SHELL = /bin/bash

DRY_RUN_INSTALL_OPTIONS := $(if $(DRY_RUN),--debug --dry-run,)
HELM_VALUES_FILES_OPTIONS := $(foreach file,$(HELM_VALUES_FILES),--values $(file))

# Parameters
# - HELM_VALUES_FILES: space-separated file path of values.yml files to use with `helm install` commands
# - DRY_RUN=true: enable dry run
# - NAMESPACE: namespace where kube resources are created

.PHONY: install-minio-setup install-spark-setup

install-minio-setup:
	helm upgrade --install ${DRY_RUN_INSTALL_OPTIONS} ${HELM_VALUES_FILES_OPTIONS} minio-setup ./minio-setup --namespace="${NAMESPACE}" --create-namespace
	
install-spark-setup:
	helm upgrade --install ${DRY_RUN_INSTALL_OPTIONS} ${HELM_VALUES_FILES_OPTIONS} spark-setup ./spark-setup --namespace="${NAMESPACE}" --create-namespace