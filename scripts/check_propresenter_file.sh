#!/bin/bash
# 
# Check propresenter file integrity (pro6)
#  - works only in Mac or Linux
#

BASE=$(basename $0)
TEST=0

####################
# check input file #
####################
usage() {
    echo
    echo "  Usage: $BASE <input_filename>"
    echo
}
if [ -z $1 ]; then
    echo "Missing \"input_filename\"!"
    usage
    exit 1
fi
if [ ! -f $1 ]; then
    echo "Error: \"$1\" does not exist!"
    usage
    exit 1
fi
if [[ ! $1 =~ pro6plx$ ]]; then
    echo "Error: \"$1\" should be *.pro6plx file!"
    usage
    exit 1
fi
FILE=$1

################
# extract file #
################
WORKDIR="/tmp/$BASE."$(date +%Y%m%d%H%M)
mkdir -p $WORKDIR
unzip -qq $FILE -d $WORKDIR 2>/dev/null
chmod -R a+r $WORKDIR

###################
# verify contents #
###################
pushd $WORKDIR > /dev/null

# test 1 - check files in source->file->reference in the files
for i in `grep -oh 'source="file:[^ ]*"' *.pro6*`; do 
    FILE=$(echo $i | sed 's|source="file:///||g' | sed 's|"$||g'| perl -pe 's/\%(\w\w)/chr hex $1/ge'); 
    if [ ! -f "$FILE" ]; then
        echo "FAILED: \"/$FILE\" does not exist!";
    fi 
done

# test 2 - find 0 byte file
find . -size 0 | sed 's|^\.\/||g' | while read LINE; do
    echo "FAILED: \"/$LINE\" is empty!"
done
popd > /dev/null

###########
# cleanup #
###########
rm -fr $WORKDIR
