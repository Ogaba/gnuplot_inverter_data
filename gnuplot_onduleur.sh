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

# Need GNU Path
export PATH=/opt/freeware/bin:$PATH

_NIVEAU_TRACE=1
_DATE="$2"

# Gnuplot Data
_TMP=~/tmp/$0.tmp.$$
_TMPDATA=~/tmp/$0.tmpdata.$$

grep -h "$_DATE" csv/"$1".csv > $_TMPDATA
[ ! -s "$_TMPDATA" ] && exit 1

f_trace 2 "Begining $0 for day $_DATE :"

# Generate Plot if data exists
# 1
>$_TMP
f_set_common
_FICPNG=gnuplot/${_DATE}.png

f_set_yrange 0 5000
f_set_ytics
f_set_key left
f_set_ylabel Watts

f_set_y2range 0 50
f_set_y2tics
f_set_key right
f_set_y2label Ampères

echo "plot \"$_TMPDATA\" u 2:8 w boxes axis x1y1 t \"Output active power\" ls 19, \"$_TMPDATA\" u 2:6 w boxes axis x1y1 t \"PV input power\" ls 5, \"$_TMPDATA\" u 2:12 w boxes axis x1y2 t \"Battery discharge current\" ls 11, \"$_TMPDATA\" u 2:11 w boxes axis x1y2 t \"Battery charge current\" ls 10" >> $_TMP

f_trace 2 " adding ${_DATE} from ${_TMPDATA} ..."
f_trace 2 " generating ${_FICPNG} ..."
echo "EOF" >> $_TMP
chmod u+x $_TMP
$_TMP > ${_FICPNG}

# 2
>$_TMP
f_set_common
_FICPNG=gnuplot/${_DATE}.volts.png

f_set_yrange 46 58.5
f_set_ytics
f_set_key left
f_set_ylabel Volts

echo "plot \"$_TMPDATA\" u 2:9 w line axis x1y1 t \"Batterie Voltage\" ls 8" >> $_TMP

f_trace 2 " adding ${_DATE} from ${_TMPDATA} ..."
f_trace 2 " generating ${_FICPNG} ..."
echo "EOF" >> $_TMP
chmod u+x $_TMP
$_TMP > ${_FICPNG}

# 3
>$_TMP
f_set_common
_FICPNG=gnuplot/${_DATE}.amperes.png

f_set_yrange 0 50
f_set_ytics
f_set_key left
f_set_ylabel Ampères

echo "plot \"$_TMPDATA\" u 2:11 w line axis x1y1 t \"Charging current\" ls 10, \"$_TMPDATA\" u 2:12 w line axis x1y1 t \"Battery discharge current\" ls 11" >> $_TMP

f_trace 2 " adding ${_DATE} from ${_TMPDATA} ..."
f_trace 2 " generating ${_FICPNG} ..."
echo "EOF" >> $_TMP
chmod u+x $_TMP
$_TMP > ${_FICPNG}

# 4
>$_TMP
f_set_common
_FICPNG=gnuplot/${_DATE}.watts.png

f_set_yrange 0 5000
f_set_ytics
f_set_key left
f_set_ylabel Watts

echo "plot \"$_TMPDATA\" u 2:6 w line axis x1y1 t \"PV input power\" ls 5, \"$_TMPDATA\" u 2:8 w line axis x1y1 t \"Output active power\" ls 19" >> $_TMP

f_trace 2 " adding ${_DATE} from ${_TMPDATA} ..."
f_trace 2 " generating ${_FICPNG} ..."
echo "EOF" >> $_TMP
chmod u+x $_TMP
$_TMP > ${_FICPNG}

# Purge
rm $_TMP $_TMPDATA 2>/dev/null

# End
f_trace 2 "Ending $0"
