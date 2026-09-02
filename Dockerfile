FROM haproxy:alpine
USER root

RUN apk add --no-cache ca-certificates wget curl unzip tzdata bash

# Download Xray — fail build if download fails
RUN wget --no-check-certificate -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -j /tmp/xray.zip xray -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray.zip

RUN wget --no-check-certificate -O /usr/local/bin/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat && \
    wget --no-check-certificate -O /usr/local/bin/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat

ENV XRAY_LOCATION_ASSET=/usr/local/bin
ENV TZ=UTC

COPY config.json /etc/xray.json
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY index.html /usr/local/etc/haproxy/index.html
COPY run.sh /run.sh

# Fix line endings + permissions
RUN sed -i 's/\r$//' /run.sh && \
    chmod 755 /run.sh /usr/local/bin/xray && \
    chmod 644 /etc/xray.json /usr/local/etc/haproxy/haproxy.cfg /usr/local/etc/haproxy/index.html

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=5s --start-period=40s --retries=3 \
    CMD curl -fsS http://0.0.0.0:8080/health || exit 1

ENTRYPOINT ["/run.sh"]
