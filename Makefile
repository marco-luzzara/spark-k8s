SHELL = /bin/bash

# Commands
# - ADDITIONAL_KUBECTL_APPLY_ARGS: additional arguments to pass to `kubectl apply`

.PHONY: up down submit-job create-jar start-cluster

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

# ******************************************************
# ******************* Kubernetes *******************

start-cluster:
	kubectl apply ${ADDITIONAL_ARGS} -f 'k8s/*.yml'

# **************************************************