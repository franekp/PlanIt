FROM debian:jessie
RUN apt-get update && apt-get install -y curl apt-transport-https

RUN curl https://repo.varnish-cache.org/pkg/5.0.0/varnish_5.0.0-1_amd64.deb > /tmp/varnish.deb \
  && ! dpkg -i /tmp/varnish.deb > /dev/null 2>&1 && apt-get -f install -y \
  && dpkg -i /tmp/varnish.deb && rm /tmp/varnish.deb

RUN rm /etc/varnish/default.vcl
COPY containers/varnish/dev.vcl containers/varnish/production.vcl /etc/varnish/
