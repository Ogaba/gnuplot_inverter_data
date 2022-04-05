#!/bin/bash
#* h***************************************************************************
# Generate Gnuplot from various data collected.
#
# Author...... : Olivier Gabathuler
# Created..... : 2009-09-16 OGA V1.0.0
# Modified.... : 2022-03-06 OGA V1.1.1
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
VERSION=1.1.1

_NIVEAU_TRACE=1
_DATE="$1"

# Gnuplot Data
_TMP=~/tmp/$0.tmp.$$
_TMPDATA=~/tmp/$0.tmpdata.$$
_DATA=meteo/csv/${_DATE//-/$''}_maison_villeneuve.csv

grep -h $_DATE csv/`echo "${_DATE}" | xargs date "+%Y%m" -d`.csv > $_TMPDATA
[ ! -s "$_TMPDATA" ] && exit 1

f_trace 2 "Begining $0 for day $_DATE :"
_FICPNG=gnuplot/${_DATE}.soleil_meteo.png

# Generate Plot if data exists
>$_TMP
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

f_set_yrange 0 10000
f_set_ytics
f_set_key left
f_set_ylabel "Visibilité"

f_set_y2range 0 5000
f_set_y2tics
f_set_key right
f_set_y2label Watts

echo "plot \"$_DATA\" u 4:9 w line axis x1y1 t \"Visibility\" ls 19, \"$_TMPDATA\" u 2:6 w line axis x1y2 t \"PV input power\" ls 5" >> $_TMP

f_trace 2 " adding ${_DATE} from ${_TMPDATA} and ${_DATA}..."
f_trace 2 " generating ${_FICPNG} ..."
echo "EOF" >> $_TMP
chmod u+x $_TMP
$_TMP > ${_FICPNG}

# Purge
rm $_TMP $_TMPDATA 2>/dev/null

# End
f_trace 2 "Ending $0"
