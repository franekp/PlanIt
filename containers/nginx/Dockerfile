FROM nginx:1.10.2-alpine

COPY containers/nginx/nginx.conf /etc/nginx/conf.d/default.conf

RUN mkdir /build && mkdir /www_root && ln -s /build /www_root/static
COPY ./build/* /build/
