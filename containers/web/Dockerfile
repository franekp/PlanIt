FROM python:3.4-alpine
RUN pip install pip-tools

RUN mkdir /web
WORKDIR /web

COPY ./src/web/requirements.txt /web/
RUN pip-compile
RUN pip-sync
COPY ./src/web/* /web/
