#!/usr/bin/env bash
# Persistence wiring for the LooneyBin stats site (run with sudo). Idempotent.
# Sets up two OpenRC services:
#   looneybin-stats        -> Next.js app on 127.0.0.1:3003
#   cloudflared-looneybin  -> Cloudflare Tunnel (projectloonybin.com -> :3003)
# The tunnel is outbound-only, so nginx + port-forwarding are NOT used for this site.
set -euo pipefail

WEB="/home/timb/Documents/LooneyBin Altis Life/website"
DEPLOY="$WEB/deploy"

echo ">> app launcher -> /usr/local/bin (space-free path for supervise-daemon)"
install -m 755 "$DEPLOY/run.sh" /usr/local/bin/looneybin-stats-run

echo ">> install services"
install -m 755 "$DEPLOY/looneybin-stats"        /etc/init.d/looneybin-stats
install -m 755 "$DEPLOY/cloudflared-looneybin"  /etc/init.d/cloudflared-looneybin
rc-update add looneybin-stats default || true
rc-update add cloudflared-looneybin default || true

echo ">> stop any manual preview processes"
if command -v fuser >/dev/null 2>&1; then fuser -k 3003/tcp 2>/dev/null || true; fi
pkill -f 'cloudflared tunnel .*looneybin' 2>/dev/null || true
sleep 1

echo ">> start services"
rc-service looneybin-stats restart
sleep 3
rc-service cloudflared-looneybin restart
sleep 4

echo ">> status"
rc-service looneybin-stats status || true
rc-service cloudflared-looneybin status || true

echo ">> checks"
curl -s -o /dev/null -w "   app   127.0.0.1:3003 = %{http_code} (307 = up)\n" http://localhost:3003/ || true
curl -s -o /dev/null -w "   public www = %{http_code}\n" https://www.projectloonybin.com/ || true

echo ">> DONE — both services enabled at boot."
