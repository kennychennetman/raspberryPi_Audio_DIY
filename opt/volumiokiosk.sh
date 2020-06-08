#!/bin/bash
count=0
until netstat -nap | grep -q '127.0.0.1:3000'; do
	sleep 1
	[ "$count" -ge 120 ] && break
	((count++))
done

xset -dpms &
xset s noblank &

## display on TFT screen
export DISPLAY=:0.0
/usr/bin/chromium-browser \
    --no-touch-pinch \
    --kiosk \
    --no-first-run \
    --disable-3d-apis \
    --disable-breakpad \
    --disable-crash-reporter \
    --disable-infobars \
    --disable-session-crashed-bubble \
    --disable-translate \
    --user-data-dir='/data/volumiokiosk' --no-sandbox http://localhost:3003/display.html --incognito  
