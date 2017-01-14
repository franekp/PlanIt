#FROM jankoppe/yarn:v7.3.0-v0.18.1
FROM debian:jessie
RUN apt-get update && apt-get install -y curl apt-transport-https
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && apt-get install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install yarn

RUN mkdir /frontend
WORKDIR /frontend

COPY ./src/frontend/package.json ./src/frontend/yarn.lock /frontend/
RUN yarn install

# don't copy whole frontend directory since both on dev and production building
# the frontend will be done not in a Dockerfile but in a running container with
# appropriate volumes mounted
