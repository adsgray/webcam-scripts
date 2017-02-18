#!/bin/sh

# definitively from July 2001

PATH=/usr/local/bin:/bin:/usr/bin:/usr/X11R6/bin
XSIZE=640
YSIZE=480
SIZE=${XSIZE}x${YSIZE}
SMALLSIZE=450x338
TNRATIO=25%x25%
PREFIX=/root

function proc_detect () {
  ps luaxw | egrep "$1" | grep -v egrep
}


function take_tv_snapshot() {
	atitv -m Composite -s $XSIZE $YSIZE snap ${PREFIX}/tv.ppm
	convert ${PREFIX}/tv.ppm ${PREFIX}/tv-t.jpg
	convert -quality 100 -geometry $SMALLSIZE ${PREFIX}/tv-t.jpg ${PREFIX}/tv.jpg
}

#
# ie rotate_files("current", "bak/web")
#
function rotate_files() {
	dirprefix=$1
	fileprefix=$2

	for ct in 8 7 6 5 4 3 2 1 0; do
		mv ${dirprefix}/${fileprefix}${ct}.jpg \
			${dirprefix}/${fileprefix}$(($ct + 1)).jpg
		mv ${dirprefix}/tn/tn_${fileprefix}${ct}.jpg \
			${dirprefix}/tn/tn_${fileprefix}$(($ct + 1)).jpg
	done

	# bring in new picture
	cp ${fileprefix}.jpg ${dirprefix}/${fileprefix}0.jpg
	# generate the thumbnail
	convert -quality 75 -geometry $TNRATIO \
		${dirprefix}/${fileprefix}0.jpg ${dirprefix}/tn/tn_${fileprefix}0.jpg
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
	convert -quality 75 -geometry $TNRATIO bak/web/current0.jpg bak/web/tn/tn_current0.jpg

}

function rotate_files_ibm() {

	# rotate the files, and thumbnails
	for ct in 8 7 6 5 4 3 2 1 0; do
		mv bak/ibm/ibm${ct}.jpg bak/ibm/ibm$(($ct + 1)).jpg
		mv bak/ibm/tn/tn_ibm${ct}.jpg bak/ibm/tn/tn_ibm$(($ct + 1)).jpg
	done

	# bring in new picture
	cp ibm.jpg bak/ibm/ibm0.jpg
	# generate the thumbnail
	convert -quality 75 -geometry $TNRATIO bak/ibm/ibm0.jpg bak/ibm/tn/tn_ibm0.jpg
}

function rotate_files_tv() {

	# rotate the files, and thumbnails
	for ct in 8 7 6 5 4 3 2 1 0; do
		mv bak/tv/tv${ct}.jpg bak/tv/tv$(($ct + 1)).jpg
		mv bak/tv/tn/tn_tv${ct}.jpg bak/tv/tn/tn_tv$(($ct + 1)).jpg
	done

	# bring in new picture
	cp tv.jpg bak/tv/tv0.jpg
	# generate the thumbnail
	convert -quality 75 -geometry $TNRATIO bak/tv/tv0.jpg bak/tv/tn/tn_tv0.jpg
}

cd /usr/local/apache/htdocs/webcam

acnt=0

while [ 1 ]; do
	if [ -f /root/take_pictures.mid ]; then
		playmidi /root/take_pictures.mid &
		sleep 7
	fi

	vidcat -q 100 -d /dev/video0 \
		-s 640x480 > ${PREFIX}/webcam-t.jpg

	if [ -f /root/take_pictures.mid ]; then
		killall playmidi.bin
	fi

	convert -quality 100 -geometry $SMALLSIZE \
		${PREFIX}/webcam-t.jpg ${PREFIX}/webcam.jpg
	stamp -r /root/stamprc-web

#	vidcat -d /dev/video1 -q 100 -s 352x240 > ${PREFIX}/ibm.jpg
#	stamp -r /root/stamprc-ibm

	rotate_files_web
#	rotate_files_ibm

	TV_ON=`proc_detect xatitv`
	if [ "foo$TV_ON" = "foo" ]; then
		take_tv_snapshot
		stamp -r /root/stamprc-tv
		rotate_files_tv
	fi

	acnt=`expr $acnt + 1`
	if [ "foo$acnt" = "foo10" ]; then
		acnt=0
		# create archive
	fi

	sleep 59
done
