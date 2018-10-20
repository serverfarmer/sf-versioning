#!/bin/sh

# TODO: support for hourly/minutely is planned when needed
# (by adding more directory parts into $copy variable below)

if [ "$4" = "" ]; then
	echo "usage: save.sh <mode> <minimal-size> <base-directory> <filename>"
	exit 1
elif [ "$1" != "daily" ]; then
	echo "aborting saving $4, only daily mode is currently supported"
	exit 1
fi

mode=$1
size=$2
path=$3
file=$path/$4

# First write new file as *.new - so the previous version is still in
# place and will be overwritten only if the new version is not empty.

cat - >$file.new

# Don't save empty files. And treat files up to $size bytes as empty
# (eg. empty configuration files, with a few newline characters only).

if [ $size != 0 ] && [ ! -s $file.new ] || [ `stat -c %s $file.new` -lt $size ]; then
	exit 0
fi

day=`date +%d`
mon=`date +%m`
year=`date +%Y`

copy=$path/$year/${year}${mon}/${year}${mon}${day}

# New file is written into base directory, and then hardlinked
# inside the directory structure. So, the latest non-empty version
# can be always accessed as $3/$4, while all versions (current and
# all previous) are stored inside the directory structure.

mkdir -p $copy
ln -f $file.new $copy/$4
mv -f $file.new $file 2>/dev/null
