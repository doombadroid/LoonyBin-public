#!/usr/bin/env bash
# Launcher for the stats site. A wrapper (no args, installed to a space-free path)
# so OpenRC/supervise-daemon never has to parse the space in the project path.
cd "/home/timb/Documents/LooneyBin Altis Life/website" || exit 1
export NODE_ENV=production
exec /usr/bin/node node_modules/next/dist/bin/next start -p 3003
