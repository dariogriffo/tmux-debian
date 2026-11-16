# Compile tmux in the oldest suite's userland, so the one binary runs on
# every suite: jammy has the oldest glibc (2.35) and the oldest libevent,
# jemalloc and libsystemd of the eight.
FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV DEB_BUILD_OPTIONS=noddebs

# ARCH is the Debian architecture to build for. arm64 is cross-compiled:
# its libraries come from ports.ubuntu.com through multiarch.
ARG ARCH=amd64
ARG FULL_VERSION

RUN set -eux; \
    if [ "$ARCH" != amd64 ]; then \
        dpkg --add-architecture "$ARCH"; \
        sed -i 's/^deb /deb [arch=amd64] /' /etc/apt/sources.list; \
        for s in jammy jammy-updates jammy-security; do \
            echo "deb [arch=$ARCH] http://ports.ubuntu.com/ubuntu-ports $s main universe" >> /etc/apt/sources.list; \
        done; \
        CROSS="crossbuild-essential-$ARCH"; \
    fi; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential debhelper dpkg-dev bison pkg-config ${CROSS:-} \
        libevent-dev:$ARCH libjemalloc-dev:$ARCH libsystemd-dev:$ARCH; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY out/src/ /build/

RUN dpkg-source -x "tmux_${FULL_VERSION}.dsc" tmux \
 && cd tmux \
 && dpkg-buildpackage -b -us -uc -Zxz --host-arch "${ARCH}"

RUN mkdir -p /out && cp /build/tmux_*.deb /out/ && chmod 644 /out/*.deb
