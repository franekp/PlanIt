FROM python:3.4-alpine
ADD . /web
WORKDIR /web
RUN pip install pip-tools
RUN pip-sync
