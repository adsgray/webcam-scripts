#!/bin/sh

PREFIX=/root/webcam

#
# default sleeptime is 1 minute
#
if [ "foo$1" = "foo" ]; then
	sleeptime=60
else
	sleeptime=$1
fi

echo $sleeptime > ${PREFIX}/webcam_sleeptime

