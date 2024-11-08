SHELL = /bin/bash

.PHONY: up down run-spark

up:
	set -a && \
	source .env && \
	set +a && \
	docker compose up -d

down:
	docker compose down -v

run-spark:
	set -a && \
	source .env && \
	set +a && \
	docker compose exec spark-master /opt/spark/bin/spark-submit \
		--class it.unimi.SparkSample \
  		--master spark://spark-master:7077 \
		--deploy-mode cluster \
		--conf spark.hadoop.fs.s3a.aws.credentials.provider=org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider \
		--conf spark.hadoop.fs.s3a.endpoint=minio:9000 \
		--conf spark.hadoop.fs.s3a.access.key=$$MINIO_ROOT_USER \
		--conf spark.hadoop.fs.s3a.secret.key=$$MINIO_ROOT_PASSWORD \
		--conf "spark.driver.extraJavaOptions=--add-exports=java.base/sun.nio.ch=ALL-UNNAMED" \
		--conf "spark.executor.extraJavaOptions=--add-exports=java.base/sun.nio.ch=ALL-UNNAMED" \
		file:///jobs/sparksample.jar \
		s3a://datasets/d1.csv \
		s3a://output/sparksample-output
		# s3a://jobs/sparksample.jar \
		# s3a://datasets/d1.csv \
		# s3a://output/sparksample-output