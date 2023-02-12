FROM python:latest
WORKDIR /root
RUN apt update && apt install -y default-jdk
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY /code/ingest.py ingest.py
COPY /code/process.py process.py
CMD python ingest.py;python process.py;python -m http.server 8000