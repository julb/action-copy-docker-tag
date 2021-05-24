FROM docker:latest

RUN apk add --no-cache jq

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]