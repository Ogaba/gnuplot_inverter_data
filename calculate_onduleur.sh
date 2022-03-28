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
. ./fonctions.sh

# Main

# Version
VERSION=1.0.0

# Temporary Data
_TMP=~/tmp/$0.tmp.$$
_TMP2=~/tmp/$0.tmp2.$$

_NIVEAU_TRACE=1
f_check_params $#
_DATE="$1"

[ -f csv/all.csv ] && grep -h "$_DATE" csv/all.csv > $_TMP
if [ ! -s "$_TMP" ]; then
	rm -f $_TMP
	exit 0
fi

f_trace 2 "Begining $0 for day $_DATE :"

_WP=`awk -F',' '{ print $7 }' $_TMP | tr '\n' '+' | sed 's/+$//' | xargs echo | bc -l`
echo -en "\tWatts produced by inverter\t : "; echo "$_WP / 60" | bc

awk -F',' '{ print $8 " " $11 }' $_TMP | grep -v -w '0\.0' | sed 's/ /*/' | bc -l > $_TMP2
_WDB=`cat $_TMP2 | tr '\n' '+' | sed 's/+$//' | xargs echo | bc -l`
[ ! -n "$_WDB" ] && _WDB=0
echo -en "\tWatts discharged by battery LTO\t : "; echo "$_WDB / 60" | bc

awk -F',' '{ print $8 " " $10 }' $_TMP | grep -v -w '0\.0' | sed 's/ /*/' | bc -l > $_TMP2
_WB=`cat $_TMP2 | tr '\n' '+' | sed 's/+$//' | xargs echo | bc -l`
echo -en "\tWatts charged by battery from s+g: "; echo "$_WB / 60" | bc

awk -F',' '{ print $8 " " $10 }' $_TMP | grep -w '2\.0' | sed 's/ /*/' | bc -l > $_TMP2
_WB=`cat $_TMP2 | tr '\n' '+' | sed 's/+$//' | xargs echo | bc -l`
echo -en "\tWatts charged by battery from g\t : "; echo "$_WB / 60" | bc

_WS=`awk -F',' '{ print $5 }' $_TMP | tr '\n' '+' | sed 's/+$//' | xargs echo | bc -l`
echo -en "\tWatts consumed from solar pannels: "; echo "$_WS / 60" | bc

_WSP=`awk -F',' '{ print $5 }' $_TMP | grep -v -w '0' | wc -l | awk '{ print $1}'`
_MAX=`awk -F',' '{ print $5 }' $_TMP | grep -v -w '0' | sort -g -r | head -n1`
_TFS=`echo "$_MAX / 2 * $_WSP / 60" | bc`
echo -en "\tWatts theorical max from solar\t : "
if [ "$_TFS" -lt 10000 ]; then
	echo "$_MAX / 2 * $_WSP / 60" | bc
else
	echo "not accurate"
fi

echo -en "\tWatts consumed from grid\t : "; echo "($_WP - $_WS) / 60" | bc

rm $_TMP $_TMP2 2>/dev/null

# End
f_trace 2 "Ending $0"
