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
		--conf "spark.driver.extraJavaOptions=--add-exports=java.base/sun.nio.ch=ALL-UNNAMED" \
		--conf "spark.executor.extraJavaOptions=--add-exports=java.base/sun.nio.ch=ALL-UNNAMED" \
		file:///jobs/sparksample.jar \
		s3a://datasets/d1.csv \
		s3a://output/sparksample-output
		# s3a://jobs/sparksample.jar \

create-jar:
	cd spark-job && \
	mvn package