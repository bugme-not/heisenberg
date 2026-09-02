FROM alpine:3.20

ADD alpine-minirootfs-3.24.1-x86_64.tar.gz / # buildkit

CMD ["/bin/sh"]

ARG TARGETPLATFORM=linux/amd64

WORKDIR /root

COPY xray.sh /root/xray.sh # buildkit

COPY config.json /etc/xray/config.json # buildkit

RUN |1 TARGETPLATFORM=linux/amd64 /bin/sh -c "set -e; \
    apk add --no-cache curl unzip wget ca-certificates bash; \
    XRAY_URL='https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip'; \
    curl -L --retry 3 -o /tmp/xray.zip $XRAY_URL || \
    curl -L --retry 3 -o /tmp/xray.zip 'https://ghproxy.com/'$XRAY_URL; \
    unzip -q /tmp/xray.zip -d /tmp && mv /tmp/xray /usr/bin/xray && chmod +x /usr/bin/xray && rm -rf /tmp/xray.zip /tmp/xray; \
    mkdir -p /usr/local/share/xray; \
    GEO_BASE='https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download'; \
    wget -q -O /usr/local/share/xray/geosite.dat $GEO_BASE'/geosite.dat' || \
    wget -q -O /usr/local/share/xray/geosite.dat 'https://ghproxy.com/'$GEO_BASE'/geosite.dat'; \
    wget -q -O /usr/local/share/xray/geoip.dat $GEO_BASE'/geoip.dat' || \
    wget -q -O /usr/local/share/xray/geoip.dat 'https://ghproxy.com/'$GEO_BASE'/geoip.dat'"

VOLUME [/etc/xray]

VOLUME [/var/log/xray]

ENV TZ=Asia/Shanghai

RUN /bin/sh -c apk add --no-cache ca-certificates bash tzdata supervisor openresty

COPY nginx.conf /etc/nginx/nginx.conf # buildkit

COPY supervisord.conf /etc/supervisord.conf # buildkit

COPY index.html /var/lib/nginx/html/index.html # buildkit

COPY entrypoint.sh /entrypoint.sh # buildkit

RUN /bin/sh -c chmod +x /root/xray.sh /entrypoint.sh

EXPOSE map[8080/tcp:{}]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
