FROM jankoppe/yarn:v7.3.0-v0.18.1

RUN mkdir /frontend
WORKDIR /frontend

COPY ./src/frontend/package.json ./src/frontend/yarn.lock /frontend/
RUN yarn install

# don't copy whole frontend directory since both on dev and production building
# the frontend will be done not in a Dockerfile but in a running container with
# appropriate volumes mounted
