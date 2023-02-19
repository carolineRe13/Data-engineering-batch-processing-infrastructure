FROM apache/spark:v3.3.1
ENV WEBUI_PORT=8081
ENV WORKER_PORT=38081
ENV MASTER_URL=spark-master:7077
ENV MEMORY=2G
USER root
RUN mkdir -p /opt/spark/logs
CMD /opt/spark/sbin/start-worker.sh --webui-port $WEBUI_PORT --port $WORKER_PORT -m $MEMORY spark://$MASTER_URL | egrep -o "/opt/spark/logs.*" | xargs tail -f