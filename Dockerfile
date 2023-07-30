FROM nginxproxy/nginx-proxy:latest

RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    cron curl nginx-module-njs \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/* 


ENV AUTO_UPGRADE=1
ENV LE_WORKING_DIR=/acme.sh
ENV LE_CONFIG_HOME=/acmecerts
RUN curl https://get.acme.sh | sh && crontab -l | sed 's#> /dev/null##' | crontab - \
    && $LE_WORKING_DIR/acme.sh --set-default-ca --server letsencrypt

VOLUME ["/acmecerts"]
EXPOSE 443

COPY nginx.tmpl /app/
COPY Procfile /app/
RUN  echo "cron: cron -f" >>/app/Procfile

COPY updatessl.sh /app/

RUN chmod +x /app/updatessl.sh

RUN mkdir -p /etc/nginx/stream.d && echo "stream { \
include /etc/nginx/stream.d/*.conf; \
}" >> /etc/nginx/nginx.conf

RUN  sed -i '1s|^|load_module modules/ngx_http_js_module.so;\n|'  /etc/nginx/nginx.conf \
  && sed -i '1s|^|load_module modules/ngx_stream_js_module.so;\n|'  /etc/nginx/nginx.conf

RUN mkdir -p /etc/nginx/socks


VOLUME ["/etc/nginx/stream.d"]

COPY entry.sh /app/
RUN chmod +x /app/entry.sh

ENTRYPOINT ["/app/entry.sh"]

CMD ["forego", "start", "-r"]


