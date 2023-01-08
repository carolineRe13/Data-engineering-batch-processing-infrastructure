FROM python:latest
COPY requirements.txt ./
RUN pip3 install -r requirements.txt
COPY /code/ingest.py /code/ingest.py
CMD ["python", "ingest.py"]