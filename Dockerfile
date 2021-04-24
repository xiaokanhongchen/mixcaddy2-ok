FROM alpine:edge

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && apk add --no-cache ca-certificates caddy  && \
    gost_URL="$(wget -qO- https://api.github.com/repos/ginuerzh/gost/releases/latest | grep -E "browser_download_url.*linux-amd64" | cut -f4 -d\")" && \
    wget -O - $gost_URL | gzip -d > /usr/bin/gost && \
    rm -rf /var/cache/apk/*
    
ADD mixcaddy.sh /mixcaddy.sh
RUN chmod +x /mixcaddy.sh

CMD /mixcaddy.sh
