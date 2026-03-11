#!/bin/bash
# Repro for https://github.com/caddyserver/caddy/issues/7559
set -euo pipefail

run_test() {
    local version=$1 caddyfile=$2
    echo "=== Caddy $version ($caddyfile) ==="
    CADDY_VERSION=$version CADDYFILE=$caddyfile docker compose up -d 2>/dev/null
    sleep 4

    local code
    printf "  wiki.test.local  → "
    code=$(curl -sk --resolve wiki.test.local:8443:127.0.0.1 https://wiki.test.local:8443/ -w "%{http_code}" -o /dev/null 2>/dev/null || true)
    echo "${code:-FAIL}"

    printf "  other.test.local → "
    code=$(curl -sk --resolve other.test.local:8443:127.0.0.1 https://other.test.local:8443/ -w "%{http_code}" -o /dev/null 2>/dev/null || true)
    echo "${code:-FAIL}"

    echo "  cert-server was called for:"
    docker compose logs cert-server 2>&1 | grep "CERT REQUESTED" | sed 's/.*CERT REQUESTED:/   /' || echo "    (nothing)"

    echo "  caddy tls handshake log:"
    docker compose logs caddy 2>&1 \
        | grep -E 'externally-managed|handshake error' \
        | sed 's/.*"msg":"\([^"]*\)".*"sni":"\([^"]*\)".*/    \2 → \1/' \
        | sed 's/.*handshake error from [^:]*:[0-9]*: \(.*\)/    \1/' \
        | sed "s/[\"'}]//g" \
        || echo "    (nothing relevant)"

    local logdir="logs-${version}"
    mkdir -p "$logdir"
    docker compose logs --no-log-prefix cert-server > "$logdir/cert-server.log" 2>&1
    docker compose logs --no-log-prefix caddy > "$logdir/caddy.log" 2>&1

    docker compose down -v 2>/dev/null
    echo ""
}

run_test 2.9.1  Caddyfile.2.9
run_test 2.11.2 Caddyfile.2.11
