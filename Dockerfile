FROM haproxy:alpine
USER root

RUN apk add --no-cache ca-certificates wget unzip tzdata

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

RUN chmod 644 /etc/xray.json /usr/local/etc/haproxy/haproxy.cfg /usr/local/etc/haproxy/index.html && \
    chmod 755 /usr/local/bin/xray

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=5s --start-period=20s --retries=3 \
    CMD wget -q --spider http://127.0.0.1:8080/health || exit 1

CMD exec /bin/sh -c '/usr/local/bin/xray run -c /etc/xray.json & PID1=$!; trap "kill $PID1; exit 0" TERM; wait $PID1'
