FROM apache/spark:latest
ENV WEBUI_PORT=8081
ENV MASTER_URL=spark://spark-master:7077
USER root
RUN mkdir -p /opt/spark/logs
CMD /opt/spark/sbin/start-worker.sh --webui-port $WEBUI_PORT $MASTER_URL | egrep -o "/opt/spark/logs.*" | xargs tail -f