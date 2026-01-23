#!/usr/bin/env bash
set -euo pipefail

say() { printf "%s\n" "$*"; }

say "[DiagnuCLI] Performance tune started"

if [ -x "/usr/sbin/periodic" ]; then
  sudo /usr/sbin/periodic daily weekly monthly
elif command -v periodic >/dev/null 2>&1; then
  sudo periodic daily weekly monthly
else
  say "[DiagnuCLI] periodic not available on this macOS version"
fi

if command -v purge >/dev/null 2>&1; then
  sudo purge
else
  say "[DiagnuCLI] purge not available on this macOS version"
fi

sudo dscacheutil -flushcache || true
sudo killall -HUP mDNSResponder || true

say "[DiagnuCLI] Performance tune finished"
