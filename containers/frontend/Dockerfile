FROM debian:jessie
RUN apt-get update && apt-get install -y curl apt-transport-https
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && apt-get install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install yarn

RUN yarn global add elm@0.18.0

RUN mkdir /frontend
WORKDIR /frontend

# don't copy whole frontend directory since both on dev and production building
# the frontend will be done not in a Dockerfile but in a running container with
# appropriate volumes mounted
# installing yarn and elm packages also is done inside a running container
