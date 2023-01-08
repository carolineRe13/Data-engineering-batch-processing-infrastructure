FROM python:latest
WORKDIR /code
COPY requirements.txt ./
RUN pip3 install -r requirements.txt
COPY ingest.py ./
CMD ["python", "ingest.py"]