SHELL = /bin/bash

.PHONY: up down submit-job create-jar

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
