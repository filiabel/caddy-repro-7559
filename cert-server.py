#!/usr/bin/env python3
"""Minimal cert server: generates a self-signed cert on every request."""

import subprocess
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse


class H(BaseHTTPRequestHandler):
    def do_GET(self):
        name = parse_qs(urlparse(self.path).query).get("server_name", ["unknown"])[0]
        print(f">>> CERT REQUESTED: {name}", flush=True)
        r = subprocess.run(
            [
                "openssl",
                "req",
                "-x509",
                "-newkey",
                "ec",
                "-pkeyopt",
                "ec_paramgen_curve:prime256v1",
                "-nodes",
                "-subj",
                f"/CN={name}",
                "-addext",
                f"subjectAltName=DNS:{name},DNS:*.test.local",
                "-days",
                "1",
                "-keyout",
                "/dev/stderr",
                "-out",
                "/dev/stdout",
            ],
            capture_output=True,
        )
        body = r.stdout + r.stderr
        self.send_response(200)
        self.end_headers()
        self.wfile.write(body)


print("cert-server listening on :9000", flush=True)
HTTPServer(("", 9000), H).serve_forever()
