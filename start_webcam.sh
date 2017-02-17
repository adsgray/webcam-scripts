#!/bin/sh

PREFIX=/root/webcam


#
# default initial sleeptime is 30 minutes
#
if [ "foo$1" = "foo" ]; then
	sleeptime=1800
else
	sleeptime=$1
fi

echo $sleeptime > ${PREFIX}/webcam_sleeptime
exec ${PREFIX}/take_pictures.sh &

