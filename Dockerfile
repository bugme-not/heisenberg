FROM haproxy:alpine
USER root

RUN apk add --no-cache ca-certificates wget curl unzip tzdata supervisor

RUN wget --no-check-certificate -qO /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -j /tmp/xray.zip xray -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray.zip

RUN wget --no-check-certificate -qO /usr/local/bin/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat && \
    wget --no-check-certificate -qO /usr/local/bin/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat

ENV XRAY_LOCATION_ASSET=/usr/local/bin
ENV TZ=UTC
ENV LANG=C.UTF-8

COPY config.json /etc/xray.json
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY index.html /usr/local/etc/haproxy/index.html
COPY supervisord.conf /etc/supervisord.conf

RUN chmod 644 /etc/xray.json /usr/local/etc/haproxy/haproxy.cfg /usr/local/etc/haproxy/index.html && \
    chmod 755 /usr/local/bin/xray

EXPOSE 8080

HEALTHCHECK --interval=15s --timeout=10s --start-period=45s --retries=5 \
    CMD curl -sf http://127.0.0.1:8080/health || exit 1

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
