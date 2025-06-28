ARG VERSION

FROM hashicorp/vault:${VERSION}

USER root
WORKDIR /app

RUN apk update &&  apk add --no-cache curl unzip groff less jq binutils aws-cli
ADD ./entrypoint.sh ./entrypoint.sh
RUN ["chmod", "+x", "./entrypoint.sh"]

USER nobody:nogroup

ENTRYPOINT [ "./entrypoint.sh" ]
