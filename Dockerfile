FROM nginx:1.16-alpine
MAINTAINER Volodymyr Marynychev <requix@gmail.com>

RUN addgroup -g 1000 -S app \
 && adduser -u 1000 -S -G app -h /var/www -s /bin/bash app

RUN touch /var/run/nginx.pid
RUN mkdir /sock

RUN apk add --no-cache \
  curl \
  openssl

RUN mkdir /etc/nginx/certs \
  && echo -e "\n\n\n\n\n\n\n" | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certs/nginx.key -out /etc/nginx/certs/nginx.crt
RUN ( \
  cd /usr/local/bin/ \
  && curl -L https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-linux-amd64 -o mkcert \
  && chmod +x mkcert \
  )

COPY ./conf/nginx.conf /etc/nginx/
COPY ./conf/default.conf /etc/nginx/conf.d/

RUN mkdir -p /etc/nginx/html /var/www/html \
  && chown -Rf app:app \
     /etc/nginx \
     /var/www \
     /var/cache/nginx \
     /var/log/nginx \
     /var/run/nginx.pid \
     /sock

EXPOSE 8443

USER app:app

VOLUME /var/www

WORKDIR /var/www/html
