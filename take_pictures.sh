#!/bin/sh

PATH=/usr/local/bin:/bin:/usr/bin:/usr/X11R6/bin
XSIZE=640
YSIZE=480
SIZE=${XSIZE}x${YSIZE}
SMALLSIZE=450x338
TNRATIO=25%x25%
PREFIX=/root/webcam

APAPREFIX=/usr/local/apache/htdocs/webcam

. $PREFIX/../usb-lib/funcs.sh

function proc_detect () {
  ps luaxw | egrep "$1" | grep -v egrep
}



function rotate_files_web() {
	
	# rotate the files, and thumbnails
	for ct in 8 7 6 5 4 3 2 1 0; do
		mv bak/web/current${ct}.jpg bak/web/current$(($ct + 1)).jpg
		mv bak/web/tn/tn_current${ct}.jpg bak/web/tn/tn_current$(($ct + 1)).jpg
	done

	# bring in new picture
	cp current.jpg bak/web/current0.jpg
	# generate the thumbnail
	convert -quality 60 -geometry $TNRATIO bak/web/current0.jpg bak/web/tn/tn_current0.jpg

}


function take_webcam_snapshot()
{

	usb_lock

	if [ -f /$PREFIX/take_pictures.mid ]; then 
		playmidi /$PREFIX/take_pictures.mid &
		sleep 7
	fi


	vidcat -q 100 -p y -d /dev/video -f jpeg -s 640x480 > ${PREFIX}/webcam-t.jpg
	logger "took webcam snapshot"

	if [ -f /$PREFIX/take_pictures.mid ]; then
		killall playmidi.bin
	fi

	convert -quality 70 \
		-geometry $SMALLSIZE \
		${PREFIX}/webcam-t.jpg ${PREFIX}/webcam.jpg

	stamp -r /${PREFIX}/stamprc-web

	usb_unlock
}

cd /usr/local/apache/htdocs/webcam

while [ 1 ]; do

	take_webcam_snapshot

	if [ `$PREFIX/imagediff.sh $APAPREFIX/current.jpg $APAPREFIX/bak/web/current0.jpg` == "different" ]; then

		rotate_files_web
	else
		logger "webcam duplicate"
	fi


	sleep `cat ${PREFIX}/webcam_sleeptime`
done
