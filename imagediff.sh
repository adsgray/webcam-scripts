#!/bin/sh

TMPDIR=/tmp
PREFIX=/root/webcam
IDIR=/usr/local/apache/htdocs/webcam

function prepare_file()
{
	fname=$1
	outtmp=$2-t.ppm
	out=$2.ppm

	convert -geometry 160x160 \
		+shade 90x150 \
		-blur 100 \
		-normalize \
		-equalize \
		$fname $outtmp

	convert -geometry 32x32 \
		-threshold 90 \
		$outtmp $out

	rm $outtmp
}

f1=$1
f2=$2

prepare_file $f1 $TMPDIR/a
prepare_file $f2 $TMPDIR/b

numdiffs=`cmp --verbose $TMPDIR/a.ppm $TMPDIR/b.ppm | wc -l`

echo "`date` $numdiffs" >> $PREFIX/imagediff.log

#rm $TMPDIR/{a.ppm,b.ppm}
convert -geometry 100x100 $TMPDIR/a.ppm $IDIR/a.jpg
convert -geometry 100x100 $TMPDIR/b.ppm $IDIR/b.jpg

if [ $numdiffs -lt 120 ]; then
	echo same
	echo same > $IDIR/comparison.txt
else
	echo different
	echo different > $IDIR/comparison.txt
fi
