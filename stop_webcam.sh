#!/bin/sh

PREFIX=/root/webcam

#killall take_pictures.sh

pid=`ps auxww|grep take_pictures.sh|grep -v grep|awk '{print $2}'`
kill $pid > /dev/null 2>&1

rm /home/webcam/nowlock
