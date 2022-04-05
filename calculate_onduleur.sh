#!/bin/bash
#* h***************************************************************************
# Generate various data from inverter collected.
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
# Specific GnuPlot functions
. ./fonctions.sh

# Main

# Version
VERSION=1.0.0

_NIVEAU_TRACE=1
_DATE="$2"

# Temporary Data
_TMPDATA=~/tmp/$0.tmpdata.$$
_TMP=~/tmp/$0.tmp.$$

grep -h "$_DATE" csv/"$1".csv > $_TMPDATA
[ ! -s "$_TMPDATA" ] && exit 1

f_trace 2 "Begining $0 for day $_DATE :"

_WP=`awk -F',' '{ print $8 }' $_TMPDATA | tr '\n' '+' | sed 's/+$//' | xargs echo | bc -l`
echo -en "\tWatts produced by inverter\t : "; echo "$_WP / 60" | bc

awk -F',' '{ print $9 " " $12 }' $_TMPDATA | grep -v -w '0\.0' | sed 's/ /*/' | bc -l > $_TMP
_WDB=`cat $_TMP | tr '\n' '+' | sed 's/+$//' | xargs echo | bc -l`
[ ! -n "$_WDB" ] && _WDB=0
echo -en "\tWatts discharged by battery LTO\t : "; echo "$_WDB / 60" | bc

awk -F',' '{ print $9 " " $11 }' $_TMPDATA | grep -v -w '0\.0' | sed 's/ /*/' | bc -l > $_TMP
_WB=`cat $_TMP | tr '\n' '+' | sed 's/+$//' | xargs echo | bc -l`
echo -en "\tWatts charged by battery from s+g: "; echo "$_WB / 60" | bc

awk -F',' '{ print $9 " " $11 }' $_TMPDATA | grep -w '2\.0' | sed 's/ /*/' | bc -l > $_TMP
_WB=`cat $_TMP | tr '\n' '+' | sed 's/+$//' | xargs echo | bc -l`
echo -en "\tWatts charged by battery from g\t : "; echo "$_WB / 60" | bc

_WS=`awk -F',' '{ print $6 }' $_TMPDATA | tr '\n' '+' | sed 's/+$//' | xargs echo | bc -l`
echo -en "\tWatts consumed from solar pannels: "; echo "$_WS / 60" | bc

_WSP=`awk -F',' '{ print $6 }' $_TMPDATA | grep -v -w '0' | wc -l | awk '{ print $1}'`
_MAX=`awk -F',' '{ print $6 }' $_TMPDATA | grep -v -w '0' | sort -g -r | head -n1`
_TFS=`echo "$_MAX / 2 * $_WSP / 60" | bc`
echo -en "\tWatts theorical max from solar\t : "
if [ "$_TFS" -lt 10000 ]; then
	echo "$_MAX / 2 * $_WSP / 60" | bc
else
	echo "not accurate"
fi

echo -en "\tWatts consumed from grid\t : "; echo "($_WP - $_WS) / 60" | bc

# Purge
rm $_TMP $_TMPDATA 2>/dev/null

# End
f_trace 2 "Ending $0"
