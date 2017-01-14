FROM python:3.4-alpine
RUN pip install pip-tools
RUN mkdir /worker
WORKDIR /worker
COPY ./src/worker/requirements.txt /worker/
RUN pip-sync
COPY ./src/worker/* /worker/
