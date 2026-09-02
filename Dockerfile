FROM haproxy:alpine

USER root

RUN apk add --no-cache ca-certificates wget curl unzip tzdata bash

RUN wget -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip

RUN unzip -j /tmp/xray.zip xray -d /usr/local/bin/

RUN chmod 755 /usr/local/bin/xray

RUN rm -f /tmp/xray.zip

RUN wget -O /usr/local/bin/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat

RUN wget -O /usr/local/bin/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat

RUN chmod 644 /usr/local/bin/geosite.dat /usr/local/bin/geoip.dat

ENV XRAY_LOCATION_ASSET=/usr/local/bin
ENV TZ=UTC
ENV LANG=C.UTF-8

COPY config.json /etc/xray.json
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY index.html /usr/local/etc/haproxy/index.html
COPY run.sh /run.sh

RUN sed -i 's/\r$//' /run.sh

RUN chmod 755 /run.sh

RUN chmod 644 /etc/xray.json

RUN chmod 644 /usr/local/etc/haproxy/haproxy.cfg

RUN chmod 644 /usr/local/etc/haproxy/index.html

EXPOSE 8080

ENTRYPOINT ["/run.sh"]
