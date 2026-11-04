#!/usr/bin/env bash
# Advertise loopback pipelines-proxy as HTTPS Tailscale Service pipelines (port 443).
# process-compose keeps this process up after advertise so MCP can wait on HTTPS.
# Create svc:pipelines in the Tailscale admin console (tcp:443)
# and auto-approve tag:studio if the CLI still asks for approval.
set -euo pipefail

if ! command -v tailscale >/dev/null 2>&1; then
	echo "serve: tailscale CLI is required for HTTPS names" >&2
	exit 1
fi

# Tailscale Services (svc:name -> https://name.<tailnet>) only run on tagged nodes.

serve_https() {
	local service="$1"
	local target="$2"
	echo "serve: tailscale ${service} -> ${target}" >&2
	tailscale serve --service="${service}" --https=443 --yes "${target}"
}

# Product HTTPS name is svc:pipelines. It terminates on pipelines-proxy, which
# proxies to pipelines serve on loopback :3850. Do not advertise :3850.
serve_https svc:pipelines 127.0.0.1:3860

# Drop the old public worker/admin split if this node still advertises it.
if tailscale serve --service=svc:pipelines-admin --https=443 off 2>/dev/null; then
	echo "serve: stopped leftover svc:pipelines-admin advertise" >&2
fi

echo "serve: https://pipelines.manticore-powan.ts.net (pipelines-proxy)" >&2
tailscale serve status || true

echo "serve: advertised; waiting until process-compose stops this process" >&2
trap 'exit 0' INT TERM
while true; do
	sleep 3600
done
