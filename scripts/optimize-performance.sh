#!/usr/bin/env bash
set -euo pipefail

say() { printf "%s\n" "$*"; }

say "[DiagnuCLI] Performance tune started"

sudo periodic daily weekly monthly

if command -v purge >/dev/null 2>&1; then
  sudo purge
else
  say "[DiagnuCLI] purge not available on this macOS version"
fi

sudo dscacheutil -flushcache || true
sudo killall -HUP mDNSResponder || true

say "[DiagnuCLI] Performance tune finished"
