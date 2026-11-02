#!/usr/bin/env bash
# Advertise loopback pipelines + tenant-admin as HTTPS Tailscale Services (port 443).
# process-compose keeps this process up after advertise so MCP can wait on HTTPS.
# Create svc:pipelines and svc:pipelines-admin in the Tailscale admin console (tcp:443)
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

serve_https svc:pipelines 127.0.0.1:3850
serve_https svc:pipelines-admin 127.0.0.1:3860

echo "serve: https://pipelines.manticore-powan.ts.net (pipelines serve)" >&2
echo "serve: https://pipelines-admin.manticore-powan.ts.net (tenant-admin)" >&2
tailscale serve status || true

echo "serve: advertised; waiting until process-compose stops this process" >&2
trap 'exit 0' INT TERM
while true; do
	sleep 3600
done
