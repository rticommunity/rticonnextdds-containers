#!/usr/bin/env bash
set -Eeuo pipefail

# Run the RDP client in a virtual desktop and capture the remote Admin Console.
# Screenshot processing and OCR assertions are performed by the Python test.
export DISPLAY=:99
Xvfb :99 -screen 0 1600x1000x24 -nolisten tcp >/tmp/xvfb.log 2>&1 &
xvfb_pid=$!
trap 'kill "$xvfb_pid" 2>/dev/null || true' EXIT
until xdpyinfo >/dev/null 2>&1; do sleep 1; done

openbox >/tmp/openbox.log 2>&1 &
openbox_pid=$!
trap 'kill "$openbox_pid" "$xvfb_pid" 2>/dev/null || true' EXIT
sleep 2

xfreerdp /v:127.0.0.1:3389 /u:user /p:"$RDP_PASSWORD" /cert:ignore /w:1280 /h:800 \
    -clipboard /log-level:WARN >/tmp/xfreerdp.log 2>&1 &
rdp_pid=$!

for attempt in $(seq 1 30); do
    xwininfo -root -tree >/tmp/rdp-windows.log 2>&1 || true
    if grep -qi 'FreeRDP' /tmp/rdp-windows.log; then break; fi
    if ! kill -0 "$rdp_pid" 2>/dev/null; then
        cat /tmp/xfreerdp.log
        cat /tmp/rdp-windows.log
        exit 1
    fi
    sleep 1
done

grep -qi 'FreeRDP' /tmp/rdp-windows.log
grep -q '1280x800' /tmp/rdp-windows.log
sleep 10

xwd -root -silent >/tmp/rdp-desktop.xwd
convert /tmp/rdp-desktop.xwd /tmp/rdp-desktop.png
kill "$rdp_pid" 2>/dev/null || true
wait "$rdp_pid" || true
cat /tmp/xfreerdp.log /tmp/rdp-windows.log

test -s /tmp/rdp-desktop.png
sleep 300
