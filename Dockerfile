FROM haproxy:alpine

USER root

RUN apk add --no-cache ca-certificates wget unzip supervisor

RUN wget -qO /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -j /tmp/xray.zip xray -d /usr/local/bin/ && \
    chmod 755 /usr/local/bin/xray && \
    rm -f /tmp/xray.zip

RUN wget -qO /usr/local/bin/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat && \
    wget -qO /usr/local/bin/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat

RUN chmod 644 /usr/local/bin/geosite.dat /usr/local/bin/geoip.dat

ENV XRAY_LOCATION_ASSET=/usr/local/bin
ENV TZ=UTC
ENV LANG=C.UTF-8

COPY config.json /etc/xray.json
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY index.html /usr/local/etc/haproxy/index.html
COPY supervisord.conf /etc/supervisord.conf

EXPOSE 8080

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
