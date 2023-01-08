FROM python:latest
WORKDIR /code
COPY requirements.txt ./
RUN --mount=type=cache,target=/root/.cache \
    python -m pip install -U pip setuptools wheel && \
    python -m pip install --requirement /root/requirements.txt

COPY ingest.py ./
CMD ["python", "ingest.py"]