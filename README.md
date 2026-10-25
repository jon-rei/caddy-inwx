# caddy-inwx

Docker image of [Caddy](https://caddyserver.com) with the
[INWX DNS provider module](https://github.com/caddy-dns/inwx) (`dns.providers.inwx`)
built in, for issuing certificates via the ACME DNS challenge against domains
hosted at [INWX](https://www.inwx.com).

Published to GHCR for `linux/amd64`, `linux/arm64` and `linux/arm/v7`:

```
ghcr.io/jon-rei/caddy-inwx
```

## Tags

Image tags mirror the bundled Caddy version:

| Tag       | Meaning                          |
| --------- | -------------------------------- |
| `latest`  | Latest published build           |
| `2`       | Latest Caddy 2.x                 |
| `2.11`    | Latest Caddy 2.11.x              |
| `2.11.7`  | Caddy 2.11.7                     |

Each image bundles a pinned version of the
[`caddy-dns/inwx`](https://github.com/caddy-dns/inwx) module.

## Usage

`compose.yaml`:

```yaml
services:
  caddy:
    image: ghcr.io/jon-rei/caddy-inwx:2
    restart: unless-stopped
    cap_add:
      - NET_ADMIN # lets Caddy raise UDP buffer sizes for HTTP/3
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    env_file: .env # INWX_USERNAME, INWX_PASSWORD
    volumes:
      - ./conf:/etc/caddy
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_data:
  caddy_config:
```

Keep the `/data` volume: it holds the certificates and ACME account. Without
it every container recreation requests new certificates and quickly runs into
Let's Encrypt rate limits. `./conf` is mounted as a directory (not just the
Caddyfile) so edits are picked up by `docker compose exec caddy caddy reload
--config /etc/caddy/Caddyfile`.

Or with `docker run`:

```console
docker run -d --name caddy \
  -p 80:80 -p 443:443 -p 443:443/udp \
  -v ./conf:/etc/caddy \
  -v caddy_data:/data \
  -v caddy_config:/config \
  --env-file .env \
  ghcr.io/jon-rei/caddy-inwx:2
```

`conf/Caddyfile`:

```caddyfile
example.com {
    tls {
        dns inwx {
            username {$INWX_USERNAME}
            password {$INWX_PASSWORD}
        }
    }
    respond "Hello"
}
```

**Use a dedicated INWX sub-account**, not your main account: create one in the
INWX account settings and restrict it to the *DNS management* role. If its
credentials leak, they can only change DNS records, not transfer or delete
domains, and your main account keeps 2FA enabled. The
[certbot INWX plugin](https://github.com/oGGy990/certbot-dns-inwx#installation)
recommends the same.

- For testing against the INWX sandbox, set
  `endpoint_url https://api.ote.domrobot.com/jsonrpc/` in the `dns inwx` block.
- For all options, see the
  [module README](https://github.com/caddy-dns/inwx#readme).

Avoid putting credentials directly in the Caddyfile; use environment variables
(`{$VAR}` placeholders, as above) and pass them with an env file, or use
Docker/Kubernetes secrets.

## How it is built

The `Dockerfile` follows the
[Caddy-documented custom-build pattern](https://caddyserver.com/docs/build#docker):
`xcaddy build` in the `caddy:<version>-builder` image, then the binary is copied
on top of the official `caddy:<version>` image. The builder stage is pinned to
`$BUILDPLATFORM` and cross-compiles with `GOOS`/`GOARCH`, so multi-arch builds
run at native speed without QEMU.

The Caddy images (tag and digest) and the INWX module version are pinned in the
`Dockerfile` and kept current by [Renovate](https://docs.renovatebot.com/)
(`renovate.json`). Caddy minor/patch releases and upstream rebuilds of the
same Caddy tag (new digest, e.g. an Alpine or Go update) are merged
automatically once CI passes; Caddy majors and module updates wait for review.

## CI

GitHub Actions (`.github/workflows/build.yml`) builds all platforms on every
pull request (no push). Pushes to `main` that change the `Dockerfile` or the
workflow publish to GHCR, using the built-in `GITHUB_TOKEN` — no extra secrets
required. Before publishing, a smoke test checks that the image runs and that
`dns.providers.inwx` is present at the pinned version.

> The GHCR package is created as **private** on first push. To make the image
> publicly pullable, change the package visibility to public in the GitHub
> package settings.

## License

[MIT](LICENSE)
