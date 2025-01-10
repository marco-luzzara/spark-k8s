ARG SPARK_IMAGE=spark:3.5.3-java17
FROM ${SPARK_IMAGE}

# Switch to user root so we can add additional jars and configuration files.
USER root

# Setup for the Prometheus JMX exporter.
# Add the Prometheus JMX exporter Java agent jar for exposing metrics sent to the JmxSink to Prometheus.
ADD https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.11.0/jmx_prometheus_javaagent-0.11.0.jar /prometheus/
RUN chmod 644 /prometheus/jmx_prometheus_javaagent-0.11.0.jar

RUN mkdir -p /etc/metrics/conf && chown spark:spark /etc/metrics/conf

USER spark

COPY conf/metrics.properties /etc/metrics/conf
COPY conf/prometheus.yaml /etc/metrics/conf
COPY extra-jars-1.0.0-jar-with-dependencies.jar $SPARK_HOME/jars/

# For additional dependencies, add them to a custom folder and set spark.jars option accordingly
# COPY additional-deps.jar $SPARK_HOME/extra-jars/

