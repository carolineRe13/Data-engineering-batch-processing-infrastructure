FROM python:latest
WORKDIR /root
RUN apt update && apt install -y default-jdk
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY /code/* ./
# always call teardown script, even if a previous step fails
CMD python wait_for_permissions.py && python ingest.py && python process.py; python call_teardown.py