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
_DATA=meteo/csv/${_DATE//-/$''}_maison_villeneuve.csv

[ ! -s "$_DATA" ] && exit 1

_FICPNG=gnuplot/${_DATE}.meteo.png

# Generate Plot if data exists
>$_TMP
f_set_terminal_png 5000 2600
f_set_margins
f_set_transparency_colors
f_set_styleline 2

f_set_multiplot
f_set_title "Données issues de OpenWeatherMap.org"
f_set_xlabel "journée du $_DATE"
f_set_datafile_sep ","

f_set_xdata_time
f_set_timefmt
f_set_format_x
f_set_tics_scale 3
f_set_grid

f_set_yrange 0 50
f_set_ytics
f_set_key left
f_set_ylabel Celcius

f_set_y2range 0 100
f_set_y2tics
f_set_y2label Pourcentage

echo "plot \"$_DATA\" u 4:5 w line axis x1y1 t \"Température\" ls 5" >> $_TMP
f_set_key right
echo "plot \"$_DATA\" u 4:6 w line axis x1y2 t \"Humidité\" ls 7, \"$_DATA\" u 4:8 w line axis x1y2 t \"Nuages\" ls 19" >> $_TMP

f_trace 2 " adding ${_DATE} from ${_DATA} ..."
f_trace 2 " generating ${_FICPNG} ..."
echo "EOF" >> $_TMP
chmod u+x $_TMP
$_TMP > ${_FICPNG}

# Purge
rm $_TMP 2>/dev/null

# End
f_trace 2 "Ending $0"
