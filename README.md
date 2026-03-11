### Minimal reproduction for [caddyserver/caddy#7559](https://github.com/caddyserver/caddy/issues/7559)

Reproduction was created with the assistance of Claude Opus 4.6

Script output:
```sh
=== Caddy 2.9.1 (Caddyfile.2.9) ===
  wiki.test.local  → 200
  other.test.local → 200
  cert-server was called for:
    wiki.test.local
    other.test.local
  caddy tls handshake log:
    wiki.test.local → using externally-managed certificate
    other.test.local → using externally-managed certificate

=== Caddy 2.11.2 (Caddyfile.2.11) ===
  wiki.test.local  → 000
  other.test.local → 200
  cert-server was called for:
    other.test.local
  caddy tls handshake log:
    no certificate available for wiki.test.local
    other.test.local → using externally-managed certificate
```
