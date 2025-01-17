SHELL := /bin/bash

DRY_RUN_INSTALL_OPTIONS := $(if $(DRY_RUN),--debug --dry-run,)
HELM_VALUES_FILES_OPTIONS := $(foreach file,$(HELM_VALUES_FILES),--values $(file))
CREATE_NS_OPTION := $(if $(CREATE_NS),--create-namespace,)
KUBE_CONTEXT := $(shell kubectl config current-context)
MAKE_CFG_PATH ?= makefile-includes/${KUBE_CONTEXT}.mk

-include ${MAKE_CFG_PATH}

.PHONY: install uninstall run-spark-task delete-task build-airflow-image setup-airflow

# Parameters \
- HELM_VALUES_FILES: space-separated file path of values.yml files to use with `helm install` commands \
- DRY_RUN=true: enable dry run \
- NAMESPACE: namespace where kube resources are created \
- CREATE_NS: create namespace if does not exist yet
install:
	helm upgrade --install --wait ${DRY_RUN_INSTALL_OPTIONS} ${HELM_VALUES_FILES_OPTIONS} pipeline-demo ./pipeline-demo --namespace="${NAMESPACE}" ${CREATE_NS_OPTION}
	

# Parameters \
- NAMESPACE: namespace where kube resources are created \
- RELEASE_NAME: helm release name
install-airflow:
	helm repo add apache-airflow https://airflow.apache.org
	helm repo update apache-airflow
	helm upgrade --install ${RELEASE_NAME}-airflow apache-airflow/airflow \
		--namespace ${NAMESPACE} \
		--values <(kubectl get configmap ${RELEASE_NAME}-airflow-configmap -o=jsonpath='{.data.override-values\.yaml}')


# Parameters \
- NAMESPACE: namespace where kube resources are created \
- RELEASE_NAME: helm release name
install-prometheus:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update prometheus-community

	helm upgrade --install ${RELEASE_NAME}-prometheus-stack prometheus-community/kube-prometheus-stack \
		--namespace ${NAMESPACE} \
		--values <(kubectl get configmap ${RELEASE_NAME}-prometheus-configmap -o=jsonpath='{.data.override-values\.yaml}')
		

# Parameters \
- NAMESPACE: namespace where kube resources are created \
- RELEASE_NAME: helm release name
install-spark-operator:
	helm repo add spark-operator https://kubeflow.github.io/spark-operator
	helm repo update spark-operator

	helm upgrade --install ${RELEASE_NAME}-spark-operator spark-operator/spark-operator \
		--namespace ${NAMESPACE} \
		--values <(kubectl get configmap ${RELEASE_NAME}-spark-operator-configmap -o=jsonpath='{.data.override-values\.yaml}')


# Parameters \
- NAMESPACE: namespace where kube resources have been created \
- RELEASE_NAME: helm release name
uninstall:
	helm uninstall --wait ${RELEASE_NAME} --namespace="${NAMESPACE}" || echo "No ${RELEASE_NAME} release found"
	helm uninstall --wait ${RELEASE_NAME}-airflow --namespace="${NAMESPACE}" || echo "No airflow release found"
	helm uninstall --wait ${RELEASE_NAME}-spark-operator --namespace="${NAMESPACE}" || echo "No spark operator release found"
	helm uninstall --wait ${RELEASE_NAME}-prometheus --namespace="${NAMESPACE}" || echo "No prometheus release found"
	kubectl delete all,configmap,secret -l app.kubernetes.io/name=${RELEASE_NAME}


# Parameters \
- HELM_VALUES_FILES: space-separated file path of values.yml files to use with `helm install` commands \
- DRY_RUN=true: enable dry run \
- NAMESPACE: namespace where kube resources are created \
- SPARK_TASK: name of the spark task to run \
- USE_SPARK_SUBMIT: if true, deploy using spark-submit. otherwise deploy using SparkApplication custom resource (default: false)
USE_SPARK_SUBMIT ?= false
run-spark-task:
	helm upgrade --install ${DRY_RUN_INSTALL_OPTIONS} ${HELM_VALUES_FILES_OPTIONS} spark-task-${SPARK_TASK} ./run-spark-task \
		--namespace="${NAMESPACE}" --set doRunWithSparkSubmit=${USE_SPARK_SUBMIT}


# Parameters \
- SPARK_TASK: name of the spark task to run
delete-spark-task:
	helm uninstall spark-task-${SPARK_TASK}
	# garbage collect the driver pod
	kubectl delete pod --selector="createdByServiceAccount=true"


# Parameters \
- IMAGE_TAG: image tag for airflow
build-airflow-image:
	docker build -t ${IMAGE_TAG} ./airflow


# Parameters \
- AIRFLOW_POD_NAME: airflow worker pod name
add-in-cluster-conn-airflow:
	kubectl exec -it ${AIRFLOW_POD_NAME} -- airflow connections add --conn-json "\
		{ \
			\"description\": \"K8S connections for deploying pods in the same cluster\", \
			\"conn_type\": \"kubernetes\", \
			\"extra\": { \
				\"in_cluster\": true \
			} \
		}" \
		in_cluster_connection

# Parameters \
- AIRFLOW_POD_NAME: airflow worker pod name \
- CONNECTION_NAME: name of the airflow connection \
- CONNECTION_JSON: json description of the connection (to generate using `generate-kube-config`) \
- CONNECTION_DESCRIPTION: description of the kube connection
add-external-conn-airflow:
	ESCAPED_CONNECTION_JSON=$$(echo -n '${CONNECTION_JSON}' | sed 's/\"/\\"/g') && \
	kubectl exec -it ${AIRFLOW_POD_NAME} -- airflow connections add --conn-json "\
		{ \
			\"description\": \"${CONNECTION_DESCRIPTION}\", \
			\"conn_type\": \"kubernetes\", \
			\"extra\": { \
				\"kube_config\": \"$$ESCAPED_CONNECTION_JSON\" \
			} \
		}" \
		${CONNECTION_NAME}


# Parameters \
- TOKEN_SECRET: name of the k8s secret containing the service-account token 
generate-kube-config:
	TOKEN="$$(kubectl get secret/${TOKEN_SECRET} -o=jsonpath="{ .data.token }" | base64 -d)" && \
	CA="$$(kubectl get secret/${TOKEN_SECRET} -o jsonpath="{ .data.ca\.crt }")" && \
	NAMESPACE="$$(kubectl get secret/${TOKEN_SECRET} -o jsonpath="{ .data.namespace }" | base64 -d)" && \
	K8S_ENDPOINT="$$(kubectl config view --minify --output jsonpath="{.clusters[*].cluster.server}")" && \
	CONTEXT_NAME="$$(kubectl config view --minify --output jsonpath="{.contexts[0].name}")" && \
	echo "{ \
		\"kind\": \"Config\", \
		\"apiVersion\": \"v1\", \
		\"preferences\": {}, \
		\"clusters\": [ \
			{ \
				\"name\": \"$$CONTEXT_NAME-cluster\", \
				\"cluster\": { \
					\"server\": \"$$K8S_ENDPOINT\", \
					\"certificate-authority-data\": \"$$CA\" \
				} \
			} \
		], \
		\"users\": [ \
			{ \
				\"name\": \"$$CONTEXT_NAME-user\", \
				\"user\": { \
					\"token\": \"$$TOKEN\" \
				} \
			} \
		], \
		\"contexts\": [ \
			{ \
				\"name\": \"$$CONTEXT_NAME-context\", \
				\"context\": { \
					\"cluster\": \"$$CONTEXT_NAME-cluster\", \
					\"user\": \"$$CONTEXT_NAME-user\", \
					\"namespace\": \"$$NAMESPACE\" \
				} \
			} \
		], \
		\"current-context\": \"$$CONTEXT_NAME-context\" \
	}" | sed 's/	//g'


# Parameters \
- NAMESPACE: namespace \
- RELEASE_NAME: helm release name
airflow-ui:
	kubectl port-forward svc/${RELEASE_NAME}-airflow-webserver 8080:8080 --namespace ${NAMESPACE}


# Parameters \
- NAMESPACE: namespace 
prometheus-ui:
	kubectl port-forward svc/prometheus-operated 9090:9090 --namespace ${NAMESPACE}