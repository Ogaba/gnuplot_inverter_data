#!/bin/bash
#* h***************************************************************************
# Generate various data from enedis collected.
#
# Author...... : Olivier Gabathuler
# Created..... : 2022-03-14 OGA V1.0.0
# Modified.... : 
# Notes....... :
#
# Miscellaneous.
# --------------
# - Version: don't forget to update VERSION (look for VERSION below)!
# - Exit codes EXIT_xxxx are for internal use (see below).
#
#**************************************************************************h *#
. ./fonctions.sh

# Main

# Version
VERSION=1.0.0

# Temporary Data
_TMP=~/tmp/$0.tmp.$$

_NIVEAU_TRACE=1
f_check_params $#
_DATE="$1"

_DATE2=`echo "${_DATE}" | xargs date "+%d/%m/%Y" -d`
_DATE3=`echo "${_DATE}" | xargs date "+%d\/%m\/%Y" -d`

if [ -f csv/enedis.csv ]; then
	_CMD="awk -v date=\"$_DATE2\" '/${_DATE3};;/ { print substr(\$0,index(\$0,date)) }' RS='^\n' csv/enedis.csv |\
	      awk '/${_DATE3};;/ { print \$0 }' RS=''"
	eval "$_CMD" 2>/dev/null | grep -v "$_DATE2" | sort -k1 -u > $_TMP
fi
if [ ! -s "$_TMP" ]; then
	rm -f $_TMP
	exit 0
fi

f_trace 2 "Begining $0 for day $_DATE :"

_WE=`awk -F';' '{ print $2 }' $_TMP | tr '\n' '+' | sed -e 's/^+//' -e 's/+$//' | xargs echo | bc -l`
echo -en "\tWatts total consumed from grid\t : "; echo "$_WE / 2" | bc

rm $_TMP 2>/dev/null

# End
f_trace 2 "Ending $0"
