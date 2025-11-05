ARG LGOGDOWNLOADER_VERSION=3.18
ARG LGOGDOWNLOADER_SHA256=1974f09cb0e0cdfed536937335488548addd92e5c654f4229ac22594a22f8ae0
ARG ALPINE_VERSION=3.22.2


FROM alpine:${ALPINE_VERSION} AS build

RUN apk add --no-cache \
    ca-certificates \
    && apk add --no-cache \
    build-base curl-dev boost-dev jsoncpp-dev rhash-dev tidyhtml-dev tinyxml2-dev cmake pkgconf zlib-dev ninja

ARG LGOGDOWNLOADER_VERSION
ARG LGOGDOWNLOADER_SHA256
RUN wget --no-cache -O /tmp/lgogdownloader.tar.gz "https://github.com/Sude-/lgogdownloader/releases/download/v${LGOGDOWNLOADER_VERSION}/lgogdownloader-${LGOGDOWNLOADER_VERSION}.tar.gz" \
    && echo "${LGOGDOWNLOADER_SHA256}  /tmp/lgogdownloader.tar.gz" | sha256sum -sc  \
    && mkdir -p /src \
    && tar -xzf /tmp/lgogdownloader.tar.gz -C /src --strip-components=1

WORKDIR /src
RUN cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DUSE_QT_GUI=OFF -GNinja \
    && ninja -Cbuild install


FROM alpine:${ALPINE_VERSION}

ARG LGOGDOWNLOADER_VERSION
LABEL org.opencontainers.image.description="Lightweight LGOGDownloader Docker image" \
      org.opencontainers.image.version="${LGOGDOWNLOADER_VERSION}" \
      org.opencontainers.image.source="https://github.com/v-sayapin/docker-lgogdownloader" \
      org.opencontainers.image.authors="v-sayapin <70110788+v-sayapin@users.noreply.github.com>"

HEALTHCHECK --interval=1h --timeout=1m --start-period=1h \
    CMD /usr/bin/lgogdownloader --check-login-status || exit 1

ENV HOME=/home/gog \
    XDG_CONFIG_HOME=/config \
    XDG_CACHE_HOME=/cache \
    DOWNLOAD_DIR=/downloads

RUN addgroup -g 1000 gog \
    && adduser -u 1000 -G gog -s /bin/sh -D gog \
    && mkdir -p \
        "${HOME}" \
        "${XDG_CONFIG_HOME}/lgogdownloader" \
        "${XDG_CACHE_HOME}/lgogdownloader" \
        "${DOWNLOAD_DIR}" \
    && chown -R gog:gog "${HOME}" \
    && apk add --no-cache \
    ca-certificates \
    && apk add --no-cache \
    libcurl rhash jsoncpp tidyhtml tinyxml2 boost-regex boost-date_time boost-system boost-filesystem \
    boost-program_options boost-iostreams zlib

COPY --from=build --chown=gog:gog /usr/bin/lgogdownloader /usr/bin

USER gog
WORKDIR "${DOWNLOAD_DIR}"
VOLUME ["${XDG_CONFIG_HOME}/lgogdownloader", "${XDG_CACHE_HOME}/lgogdownloader", "${DOWNLOAD_DIR}"]

ENTRYPOINT ["/usr/bin/lgogdownloader"]
