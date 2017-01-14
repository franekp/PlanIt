FROM nginx:1.10.2-alpine

RUN cat /etc/nginx/conf.d/default.conf
COPY containers/nginx/nginx.conf /etc/nginx/conf.d/default.conf

RUN mkdir /build && mkdir /www_root && ln -s /build /www_root/static
COPY ./build/* /build/
