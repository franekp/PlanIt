FROM python:3.4-alpine
RUN pip install pip-tools

RUN mkdir /worker
WORKDIR /worker

COPY ./src/worker/requirements.in ./src/worker/requirements.txt /worker/
RUN pip-compile && pip-sync && mv requirements.txt /tmp/requirements.txt
COPY ./src/worker /worker
RUN mv /tmp/requirements.txt requirements.txt
