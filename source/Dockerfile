FROM ubuntu:latest
LABEL maintainer="Chillily "
USER root
WORKDIR /mini_s/
RUN apt update && \
apt install -y nginx && \
apt install libfcgi-dev -y && \
apt install spawn-fcgi -y && \
rm -rf /var/lib/apt/lists && \
useradd serveruser
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY mini_server /mini_s/mini_server
COPY entry.sh /mini_s/entry.sh
RUN chown -R serveruser:serveruser /etc/nginx /mini_s /run /var/lib/nginx /var/log/nginx && \
chmod ugo+rwxs /etc/nginx/nginx.conf
USER serveruser
ENTRYPOINT ["/mini_s/entry.sh"]