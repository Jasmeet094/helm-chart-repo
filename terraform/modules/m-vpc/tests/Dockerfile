FROM alpine:3.10

RUN apk update &&\
  apk add jq bash curl ruby ruby-etc ruby-bigdecimal ruby-dev ruby-rdoc build-base openssh terraform

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
