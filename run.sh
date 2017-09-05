#!/bin/bash

# This is the script I use on a Raspberry Pi to launch CalmLink.  
# Notice it creates a log file in the current directory.

# If you copy this script to /home/svxlink/run.sh and then add
# this one line to your /etc/rc.local
#     nohup /bin/su -l -c '/bin/bash /home/svxlink/run.sh' svxlink &
# then svxlink will start automaticaly on each reboot.

# By using /usr/local/calmlink/ for the CalmLink configs,
# it is compatible with the normal svxlink install under /usr/local/.
# When you "make install", svxlink will put its own scripts
# under /usr/local/etc and /usr/local/share, but will not smash
# the CalmLink scripts under /usr/local/calmlink/.

# If svxlink dies, this script sleeps 10 seconds and starts it again.
# My audio device doesn't always open on the first try, but by retrying,
# eventually it will succeed.  However if something is going really wrong,
# the crash loop can hide it.  Examine the log files from time to time!

set -x
cd $HOME

while true
do
	pactl set-sink-volume 0 50%
	pactl set-sink-volume 1 50%
	pactl set-source-volume 0 50%
	pactl set-source-volume 1 50%

	date
	/usr/local/bin/svxlink --config=/usr/local/calmlink/calmlink.conf
	date

	sleep 10
done >$(date +log.%Y-%m-%d-%H%M%S.log) 2>&1 </dev/null
