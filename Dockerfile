FROM openjdk:8-jre-alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL maintainer="CrazyMax" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="jetbrains-license-server" \
  org.label-schema.description="JetBrains License Server" \
  org.label-schema.version=$VERSION \
  org.label-schema.url="https://github.com/crazy-max/docker-jetbrains-license-server" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/crazy-max/docker-jetbrains-license-server" \
  org.label-schema.vendor="CrazyMax" \
  org.label-schema.schema-version="1.0"

ENV JLS_PATH="/opt/jetbrains-license-server" \
  JLS_VERSION="18692" \
  JLS_SHA256="e71c4abae7d144dda7af5775dd6812e93d5934de39134d97420b4b0db29e16f4"

COPY entrypoint.sh /entrypoint.sh

RUN apk --update --no-cache add \
    tzdata \
  && apk --update --no-cache add -t build-dependencies \
    curl zip \
  && mkdir -p "$JLS_PATH" \
  && curl -L "https://download.jetbrains.com/lcsrv/license-server-installer.zip" -o "/tmp/jls.zip" \
  && echo "$JLS_SHA256  /tmp/jls.zip" | sha256sum -c - | grep OK \
  && unzip "/tmp/jls.zip" -d "$JLS_PATH" \
  && rm -f "/tmp/jls.zip" \
  && chmod a+x "$JLS_PATH/bin/license-server.sh" \
  && ln -sf "$JLS_PATH/bin/license-server.sh" "/usr/local/bin/license-server" \
  && chmod a+x /entrypoint.sh \
  && apk del build-dependencies \
  && rm -rf /var/cache/apk/* /tmp/*

EXPOSE 8000
VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/local/bin/license-server", "run" ]
