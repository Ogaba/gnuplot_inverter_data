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
# Fonctions communes GnuPlot
. ./fonctions.sh

# Main

# Version
VERSION=1.1.1

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
_FICPNG=gnuplot/${_DATE}.watts.png

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
