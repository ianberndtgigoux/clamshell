#!/bin/bash
# Instala clamshell y su watchdog. Requiere sudo.
set -eu
[ "$(id -u)" = "0" ] || { echo "usá: sudo ./instalar.sh" >&2; exit 1; }
D="$(cd "$(dirname "$0")" && pwd)"
install -m 755 "$D/clamshell" /usr/local/bin/clamshell
install -m 644 "$D/cl.clamshell.watchdog.plist" /Library/LaunchDaemons/cl.clamshell.watchdog.plist
launchctl bootout system/cl.clamshell.watchdog 2>/dev/null || true
launchctl bootstrap system /Library/LaunchDaemons/cl.clamshell.watchdog.plist
echo "listo. probá: clamshell status"
