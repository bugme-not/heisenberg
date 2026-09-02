FROM haproxy:alpine

USER root

ENV XRAY_LOCATION_ASSET=/usr/local/bin \
    TZ=UTC \
    LANG=C.UTF-8 \
    PORT=8080

RUN apk add --no-cache \
    ca-certificates \
    wget \
    curl \
    unzip \
    tzdata \
    bash

# Install Xray
RUN set -eux; \
    wget --no-check-certificate -qO /tmp/xray.zip \
        https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip; \
    unzip -j /tmp/xray.zip xray -d /usr/local/bin/; \
    chmod 755 /usr/local/bin/xray; \
    rm -f /tmp/xray.zip

# Install Xray routing databases
RUN set -eux; \
    wget --no-check-certificate -qO /usr/local/bin/geosite.dat \
        https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat; \
    wget --no-check-certificate -qO /usr/local/bin/geoip.dat \
        https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat; \
    chmod 644 \
        /usr/local/bin/geosite.dat \
        /usr/local/bin/geoip.dat

# Copy application files
COPY config.json /etc/xray.json
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY index.html /usr/local/etc/haproxy/index.html
COPY run.sh /run.sh

# Permissions
RUN set -eux; \
    chmod 644 /etc/xray.json; \
    chmod 644 /usr/local/etc/haproxy/haproxy.cfg; \
    chmod 644 /usr/local/etc/haproxy/index.html; \
    chmod 755 /run.sh /usr/local/bin/xray

# Verify Xray installation
RUN echo "===== XRAY VERSION =====" && \
    /usr/local/bin/xray version

# Verify Xray configuration
RUN echo "===== XRAY CONFIG TEST =====" && \
    /usr/local/bin/xray run -test -c /etc/xray.json

# Verify HAProxy installation and configuration
RUN echo "===== HAPROXY VERSION =====" && \
    haproxy -vv

RUN echo "===== HAPROXY CONFIG TEST =====" && \
    haproxy -c -V -f /usr/local/etc/haproxy/haproxy.cfg

EXPOSE 8080

ENTRYPOINT ["/run.sh"]
