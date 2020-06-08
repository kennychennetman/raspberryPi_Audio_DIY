#!/bin/bash
PORT=22
PUSHTIME=1

gpio -g mode $PORT in
gpio -g mode $PORT down

count=0
while [ $count -lt $PUSHTIME ]; do
	signal=$(gpio -g read $PORT)
	echo $signal
	if [ "$signal" -eq "0" ]; then
		((count++))
	else
		count=0
	fi
	sleep 0.3
done

echo "Shutdown now..."
/home/volumio/commands/shutdown.sh
