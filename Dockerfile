# Caddy with the INWX DNS provider module (dns.providers.inwx).
# Caddy tags + digests and the module version are pinned here and kept current
# by Renovate (renovate.json); a digest update follows an upstream rebuild of
# the same Caddy tag (e.g. a new Alpine or Go base).

ARG INWX_VERSION=v0.4.1

# Build on the runner's native architecture and cross-compile for the target
# platform, so multi-arch builds do not need QEMU emulation.
FROM --platform=$BUILDPLATFORM caddy:2.11.9-builder@sha256:1b828679ae08622c534d8e83ed80c6c25d343202f0586fe3b52d8e0ce33413b9 AS builder

ARG INWX_VERSION
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

# xcaddy builds the Caddy version from the builder image's CADDY_VERSION env
# and writes /usr/bin/caddy (the image's workdir). GOARM is only used for
# linux/arm (v7 -> 7).
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH GOARM=${TARGETVARIANT#v} \
    xcaddy build --with github.com/caddy-dns/inwx@${INWX_VERSION}

FROM caddy:2.11.9@sha256:0c2243efcf437ab7f7a978f1027fcf0d4f9be8a75df27b1b3fbc5dbe0ffa8cf0

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
