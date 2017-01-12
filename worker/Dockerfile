FROM python:3.4-alpine
ADD . /worker
WORKDIR /worker
RUN pip install pip-tools
RUN pip-sync
