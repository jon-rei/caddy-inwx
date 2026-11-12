# Caddy with the INWX DNS provider module (dns.providers.inwx).
# Caddy tags + digests and the module version are pinned here and kept current
# by Renovate (renovate.json); a digest update follows an upstream rebuild of
# the same Caddy tag (e.g. a new Alpine or Go base).

ARG INWX_VERSION=v0.4.1

# Build on the runner's native architecture and cross-compile for the target
# platform, so multi-arch builds do not need QEMU emulation.
FROM --platform=$BUILDPLATFORM caddy:2.11.9-builder@sha256:345264d8c6b50f44f4a4d507d4e6b6bcae40eef2f210d70f76e717fd8cc31baf AS builder

ARG INWX_VERSION
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

# xcaddy builds the Caddy version from the builder image's CADDY_VERSION env
# and writes /usr/bin/caddy (the image's workdir). GOARM is only used for
# linux/arm (v7 -> 7).
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH GOARM=${TARGETVARIANT#v} \
    xcaddy build --with github.com/caddy-dns/inwx@${INWX_VERSION}

FROM caddy:2.11.9@sha256:e40b94d0a43b5ff69cb20568d73f10c70703df7b0ffc2298eb3d723cdc9d0bd1

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
