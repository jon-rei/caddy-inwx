# Caddy with the INWX DNS provider module (dns.providers.inwx).
# Caddy tags + digests and the module version are pinned here and kept current
# by Renovate (renovate.json); a digest update follows an upstream rebuild of
# the same Caddy tag (e.g. a new Alpine or Go base).

ARG INWX_VERSION=v0.4.1

# Build on the runner's native architecture and cross-compile for the target
# platform, so multi-arch builds do not need QEMU emulation.
FROM --platform=$BUILDPLATFORM caddy:2.11.7-builder@sha256:c4cd20eaa0b69112fd5d4f721ffc9671687e1d5d0b155c8620cf7546dbef94c0 AS builder

ARG INWX_VERSION
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

# xcaddy builds the Caddy version from the builder image's CADDY_VERSION env
# and writes /usr/bin/caddy (the image's workdir). GOARM is only used for
# linux/arm (v7 -> 7).
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH GOARM=${TARGETVARIANT#v} \
    xcaddy build --with github.com/caddy-dns/inwx@${INWX_VERSION}

FROM caddy:2.11.7@sha256:36c24ad91a7ff7bc4c87fe22bfa8df3c4b18da0773d73fc12ee2c52b98c0bb7e

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
