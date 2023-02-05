FROM python:latest
WORKDIR /root
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY /code/ingest.py ingest.py
CMD python ingest.py;python -m http.server 8000