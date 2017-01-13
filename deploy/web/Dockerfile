FROM python:3.4-alpine
RUN pip install pip-tools
RUN mkdir /src
WORKDIR /src
ADD ./src/planit_web/requirements.txt /src/
RUN pip-sync
#ADD ./src/planit_web /src
