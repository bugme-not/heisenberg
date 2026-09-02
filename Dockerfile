FROM alpine:3.20

ADD alpine-minirootfs-3.24.1-x86_64.tar.gz / # buildkit

CMD ["/bin/sh"]

LABEL maintainer=Teddysun <i@teddysun.com>

ARG TARGETPLATFORM=linux/amd64

WORKDIR /root

COPY xray.sh /root/xray.sh # buildkit

COPY config.json /etc/xray/config.json # buildkit

RUN |1 TARGETPLATFORM=linux/amd64 /bin/sh -c

VOLUME [/etc/xray]

VOLUME [/var/log/xray]

ENV TZ=Asia/Shanghai

RUN /bin/sh -c apk add --no-cache ca-certificates bash curl tzdata supervisor

COPY nginx.conf /etc/nginx/nginx.conf # buildkit

COPY supervisord.conf /etc/supervisord.conf # buildkit

COPY index.html /var/lib/nginx/html/index.html # buildkit

COPY entrypoint.sh /entrypoint.sh # buildkit

RUN /bin/sh -c chmod +x /root/xray.sh /entrypoint.sh

EXPOSE map[8080/tcp:{}]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
