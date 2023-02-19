FROM apache/spark:v3.3.1
USER root
RUN mkdir -p /opt/spark/logs
CMD /opt/spark/sbin/start-master.sh | egrep -o "/opt/spark/logs.*" | xargs tail -f