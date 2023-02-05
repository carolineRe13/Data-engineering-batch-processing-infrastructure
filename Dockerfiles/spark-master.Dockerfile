FROM apache/spark:latest
USER root
RUN mkdir -p /opt/spark/logs
CMD /opt/spark/sbin/start-master.sh | egrep -o "/opt/spark/logs.*" | xargs tail -f