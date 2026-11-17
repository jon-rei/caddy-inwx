# Caddy with the INWX DNS provider module (dns.providers.inwx).
# Caddy tags + digests and the module version are pinned here and kept current
# by Renovate (renovate.json); a digest update follows an upstream rebuild of
# the same Caddy tag (e.g. a new Alpine or Go base).

ARG INWX_VERSION=v0.4.1

# Build on the runner's native architecture and cross-compile for the target
# platform, so multi-arch builds do not need QEMU emulation.
FROM --platform=$BUILDPLATFORM caddy:2.11.9-builder@sha256:f9beaa5ddbe7df6f26ebbcf9cbf44e05a1917b9bba464f0c3229038d7e2e6e13 AS builder

ARG INWX_VERSION
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

# xcaddy builds the Caddy version from the builder image's CADDY_VERSION env
# and writes /usr/bin/caddy (the image's workdir). GOARM is only used for
# linux/arm (v7 -> 7).
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH GOARM=${TARGETVARIANT#v} \
    xcaddy build --with github.com/caddy-dns/inwx@${INWX_VERSION}

FROM caddy:2.11.9@sha256:4851e54a46b206517c574821bb5cc67f170d2156041e9fbc4c9193b45e84a75b

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
