FROM python:3.4
RUN apt-get update && apt-get install -y sqlite3 postgresql-client
RUN pip install pip-tools

RUN mkdir /web
WORKDIR /web

COPY ./src/web/requirements.in ./src/web/requirements.txt /web/
RUN pip-compile && pip-sync && mv requirements.txt /tmp/requirements.txt
COPY ./src/web /web
RUN mv /tmp/requirements.txt requirements.txt
