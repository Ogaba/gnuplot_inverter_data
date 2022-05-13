#!/bin/bash
#* h***************************************************************************
# Generate Gnuplot from various data collected.
#
# Author...... : Olivier Gabathuler
# Created..... : 2009-09-16 OGA V1.0.0
# Modified.... : 2022-04-05 OGA V1.2.0
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

# Common plotting function
f_set_common () {
	f_set_terminal_png 5000 2600
	f_set_margins
	f_set_transparency_colors
	f_set_styleline 2

	f_set_multiplot
	f_set_title "Données issues de l'Onduleur PIP8048MAX"
	f_set_xlabel "journée du $_DATE"
	f_set_datafile_sep ","

	f_set_xdata_time
	f_set_timefmt
	f_set_format_x
	f_set_tics_scale 3
	f_set_grid
}

# Main

# Version
VERSION=1.2.0

_NIVEAU_TRACE=1
_DATE="$2"

# Temporary Data
_TMP=~/tmp/$0.tmp.$$
_TMPDATA=~/tmp/$0.tmpdata.$$
_TMPDATA2=~/tmp/$0.tmpenedis.$$

# Inverter
grep -h "$_DATE" csv/"$1".csv > $_TMPDATA
[ ! -s "$_TMPDATA" ] && exit 1

# Enedis
_DATE2=`echo "${_DATE}" | xargs date "+%d/%m/%Y" -d`
_DATE3=`echo "${_DATE}" | xargs date "+%d\/%m\/%Y" -d`
if [ -f csv/enedis.csv ]; then
	_CMD="awk -v date2=\"$_DATE2\" '/${_DATE3};;/ { print substr(\$0,index(\$0,date2)) }' RS='^\n' csv/enedis.csv |\
	      awk '/${_DATE3};;/ { print \$0 }' RS='' |\
	      awk -v date=\"$_DATE\" '{ print date \" \" \$0 }' |\
	      sed 's/;/,/g'"
	eval "$_CMD" 2>/dev/null | grep -v "$_DATE2" | sort -k1 -u > $_TMPDATA2
else
	f_trace 1 "csv/enedis.csv not found !"; rm -f $_TMPDATA; exit 1
fi
[ ! -s "$_TMPDATA2" ] && rm -f $_TMPDATA 2>/dev/null && exit 1

f_trace 2 "Begining $0 For day $_DATE :"
_FICPNG=gnuplot/${_DATE}.enedis.png

# Generate Plot if data exists
>$_TMP
f_set_common

f_set_yrange 0 5000
f_set_ytics
f_set_key left
f_set_ylabel Watts  

echo "plot \"$_TMPDATA\" u 2:8 w boxes axis x1y1 t \"Output active power\" ls 19, \"$_TMPDATA2\" u 1:2 w boxes axis x1y1 t \"Enedis active power\" ls 2" >> $_TMP

f_trace 2 " adding ${_DATE} from ${_TMPDATA} and ${_TMPDATA2}..."
f_trace 2 " generating ${_FICPNG} ..."
echo "EOF" >> $_TMP
chmod u+x $_TMP
$_TMP > ${_FICPNG}

# Purge
rm $_TMP $_TMPDATA $_TMPDATA2 2>/dev/null

# End
f_trace 2 "Ending $0"
