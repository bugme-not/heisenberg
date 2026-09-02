FROM alpine:3.20

CMD ["/bin/sh"]

WORKDIR /root

COPY config.json /etc/xray/config.json

RUN set -e; \
    apk add --no-cache curl unzip wget ca-certificates bash; \
    XRAY_URL='https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip'; \
    curl -L --retry 3 -o /tmp/xray.zip $XRAY_URL || \
    curl -L --retry 3 -o /tmp/xray.zip https://ghproxy.com/$XRAY_URL; \
    unzip -q /tmp/xray.zip -d /tmp && mv /tmp/xray /usr/bin/xray && chmod +x /usr/bin/xray && rm -rf /tmp/xray.zip /tmp/xray; \
    mkdir -p /usr/local/share/xray; \
    GEO_BASE='https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download'; \
    wget -q -O /usr/local/share/xray/geosite.dat $GEO_BASE/geosite.dat || \
    wget -q -O /usr/local/share/xray/geosite.dat https://ghproxy.com/$GEO_BASE/geosite.dat; \
    wget -q -O /usr/local/share/xray/geoip.dat $GEO_BASE/geoip.dat || \
    wget -q -O /usr/local/share/xray/geoip.dat https://ghproxy.com/$GEO_BASE/geoip.dat

VOLUME /etc/xray
VOLUME /var/log/xray

ENV TZ=Asia/Shanghai

RUN apk add --no-cache ca-certificates bash tzdata supervisor openresty

COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf
COPY index.html /var/lib/nginx/html/index.html
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 8080/tcp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
