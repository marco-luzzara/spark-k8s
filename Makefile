SHELL = /bin/bash

MAKE_CFG_PATH ?= makefile-includes/local.mk

-include ${MAKE_CFG_PATH}


up:
	MINIO_ROOT_USER=${MINIO_ROOT_USER} MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD} \
	MINIO_UI_PORT=${MINIO_UI_PORT} \
	SPARK_MASTER_UI_PORT=${SPARK_MASTER_UI_PORT} SPARK_WORKER_UI_PORT=${SPARK_WORKER_UI_PORT} \
	docker compose up -d


down:
	docker compose down -v


# Parameters \
- TASK_JAR: path of the task jar \
- TASK_CLASS: Java class to execute \
- TASK_ARGS: arguments of the task, passed to the jar
submit-job:
	docker compose exec spark-master /opt/spark/bin/spark-submit \
		--class ${TASK_CLASS} \
  		--master spark://spark-master:7077 \
		--deploy-mode cluster \
		${TASK_JAR} \
		${TASK_ARGS}


create-extra-deps-jar:
	( cd external-deps/ml-tasks/code && mvn install -Pextra-only; ) && \
	cp external-deps/ml-tasks/code/extra-jars/target/extra-jars-1.0.0-jar-with-dependencies.jar spark-docker/


create-task-jar:
	cd external-deps/ml-tasks/code && mvn package -Ptasks


# Parameters \
- IMAGE_TAG: image tag
build-spark-image:
	docker build -t ${IMAGE_TAG} ./spark-docker
	

# Parameters \
- MINIO_ENDPOINT: minio endpoint \
- FILE_PATH: local path of the file to load on minio \
- MINIO_PATH: path of the directory where the file will be uploaded in the minio filesystem
upload-to-minio:
	FILE_NAME=$$(basename "${FILE_PATH}") && \
	BUCKET_NAME=$$(echo "${MINIO_PATH}" | cut -d "/" -f1) && \
	docker run --rm --network=host \
		--entrypoint="bash" \
		-v "${FILE_PATH}:/uploads/$$FILE_NAME" \
		minio/mc -c "\
			mc alias set my_minio ${MINIO_ENDPOINT} ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD} && \
			mc mb --ignore-existing my_minio/$$BUCKET_NAME && \
			{ mc rm my_minio/${MINIO_PATH}/$$FILE_NAME || echo \"$$FILE_NAME is created for the first time now...\"; } && \
			mc put /uploads/$$FILE_NAME my_minio/${MINIO_PATH}/$$FILE_NAME"