SHELL = /bin/bash

# Commands
# - MINIO_ENDPOINT: used to seed minio on minikube. To get this endpoint, run `minikube tunnel` first to 
#	expose the service on localhost

.PHONY: up down submit-job create-jar start-cluster seed-minio

# ******************* Docker Compose *******************
up:
	set -a && \
	source .env && \
	set +a && \
	docker compose up -d

down:
	docker compose down -v

submit-job:
	set -a && \
	source .env && \
	set +a && \
	docker compose exec spark-master /opt/spark/bin/spark-submit \
		--class it.unimi.SparkSample \
  		--master spark://spark-master:7077 \
		--deploy-mode cluster \
		s3a://jobs/sparksample.jar \
		s3a://datasets/d1.csv \
		s3a://output/sparksample-output

	# file:///jobs/sparksample.jar \
	# s3a://jobs/sparksample.jar \

create-jar:
	( cd spark && mvn package; ) && \
	cp spark/extra-jars/target/extra-jars-1.0.0-jar-with-dependencies.jar spark-docker/


# Parameters \
- IMAGE_TAG: image tag
build-spark-image:
	docker build -t ${IMAGE_TAG} ./spark-docker
	

# Parameters \
- MINIO_ENDPOINT: minio endpoint
seed-minio:
	set -a && \
	source .env && \
	set +a && \
	docker run --rm --network=host \
		--entrypoint="bash" \
		-v "./datasets:/datasets" \
		-v "./spark/example-job/target/example-job-1.0.0-jar-with-dependencies.jar:/jobs/sparksample.jar" \
		minio/mc -c "\
			mc alias set local_minio ${MINIO_ENDPOINT} $$MINIO_ROOT_USER $$MINIO_ROOT_PASSWORD && \
			mc mb --ignore-existing local_minio/datasets && \
			mc mb --ignore-existing local_minio/jobs && \
			mc mb --ignore-existing local_minio/output && \
			mc put --if-not-exists /datasets/d1.csv local_minio/datasets && \
			mc put --if-not-exists /jobs/sparksample.jar local_minio/jobs"