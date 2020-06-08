#!/bin/bash

echo volumio | sudo -S systemctl stop volumio.service
for i in mpd.socket mpd.service volumio.service remote-fs.target
do
	echo volumio | sudo -S systemctl stop $i
done

/sbin/poweroff
