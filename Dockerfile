FROM alpine:3.20 AS xray-bin
ADD https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/x86_64/alpine-minirootfs-3.20.3-x86_64.tar.gz /xray-rootfs
WORKDIR /xray-rootfs
RUN apk add --no-cache curl unzip ca-certificates bash
WORKDIR /xray-rootfs/app
RUN curl -L --retry 3 "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip" -o xray.zip || \
    curl -L --retry 3 "https://ghproxy.com/https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip" -o xray.zip && \
    unzip -q xray.zip && chmod +x xray && mv xray /xray-rootfs/usr/local/bin/xray && rm -rf xray.zip README.md

FROM openresty/openresty:alpine-fat
ADD https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/x86_64/alpine-minirootfs-3.20.3-x86_64.tar.gz / # buildkit
CMD ["/bin/sh"]
LABEL maintainer=cxlvin
ARG TARGETPLATFORM=linux/amd64
WORKDIR /root
RUN |1 TARGETPLATFORM=linux/amd64 /bin/sh -c 'apk add --no-cache ca-certificates bash curl tzdata wget'
RUN mkdir -p /usr/local/share/xray && \
    (wget -qO /usr/local/share/xray/geosite.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat" || \
     wget -qO /usr/local/share/xray/geosite.dat "https://ghproxy.com/https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat") && \
    (wget -qO /usr/local/share/xray/geoip.dat "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat" || \
     wget -qO /usr/local/share/xray/geoip.dat "https://ghproxy.com/https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat")
COPY --from=xray-bin /xray-rootfs/usr/local/bin/xray /usr/local/bin/xray # buildkit
COPY config.json /etc/xray.json # buildkit
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf # buildkit
RUN /bin/sh -c 'chmod +x /usr/local/bin/xray && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime'
VOLUME [/etc/xray]
VOLUME [/var/log/xray]
ENV TZ=Asia/Shanghai
EXPOSE map[8080/tcp:{}]
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s CMD wget -qO- http://[::1]:8080/health || exit 1
CMD ["/bin/sh", "-c", "/usr/local/bin/xray run -c /etc/xray.json & exec /usr/local/openresty/bin/openresty -g 'daemon off;'"]
