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
add-in-cluster-conn-airflow:
	kubectl exec -it ${WORKER_POD_NAME} -- airflow connections add --conn-json "\
		{ \
			\"description\": \"K8S connections for deploying pods in the same cluster\", \
			\"conn_type\": \"kubernetes\", \
			\"extra\": { \
				\"in_cluster\": true \
			} \
		}" \
		in_cluster_connection

# Parameters \
- WORKER_POD_NAME: airflow worker pod name \
- CONNECTION_NAME: name of the airflow connection \
- CONNECTION_JSON: json description of the connection (to generate using `generate-kube-config`)
add-external-conn-airflow:
	ESCAPED_CONNECTION_JSON=$$(echo -n '${CONNECTION_JSON}' | sed 's/\"/\\\\\\"/g')
	kubectl exec -it ${WORKER_POD_NAME} -- airflow connections add --conn-json "\
		{ \
			\"description\": \"K8S connections for deploying pods in an external cluster\", \
			\"conn_type\": \"kubernetes\", \
			\"extra\": { \
				\"kube_config\": \"${ESCAPED_CONNECTION_JSON}\" \
			} \
		}" \
		${CONNECTION_NAME}


# Parameters \
- TOKEN_SECRET: name of the k8s secret containing the service-account token \
- K8S_ENDPOINT: k8s endpoint (e.g. https://localhost:6443)
generate-kube-config:
	TOKEN="$$(kubectl get secret/${TOKEN_SECRET} -o=jsonpath="{ .data.token }" | base64 -d)" && \
	CA=$$(kubectl get secret/${TOKEN_SECRET} -o jsonpath="{ .data.ca\.crt }") && \
	NAMESPACE=$$(kubectl get secret/${TOKEN_SECRET} -o jsonpath="{ .data.namespace }" | base64 -d) && \
	echo "{ \
		\"kind\": \"Config\", \
		\"apiVersion\": \"v1\", \
		\"preferences\": {}, \
		\"clusters\": [ \
			{ \
				\"name\": \"service-account-cluster\", \
				\"cluster\": { \
					\"server\": \"${K8S_ENDPOINT}\", \
					\"certificate-authority-data\": \"$$CA\" \
				} \
			} \
		], \
		\"users\": [ \
			{ \
				\"name\": \"service-account\", \
				\"user\": { \
					\"token\": \"$$TOKEN\" \
				} \
			} \
		], \
		\"contexts\": [ \
			{ \
				\"name\": \"service-account-context\", \
				\"context\": { \
					\"cluster\": \"service-account-cluster\", \
					\"user\": \"service-account\", \
					\"namespace\": \"$$NAMESPACE\" \
				} \
			} \
		], \
		\"current-context\": \"service-account-context\" \
	}" | sed 's/	//g'


# Parameters \
- NAMESPACE: namespace \
- RELEASE_NAME: helm release name
airflow-ui:
	kubectl port-forward svc/${RELEASE_NAME}-airflow-webserver 8080:8080 --namespace ${NAMESPACE}