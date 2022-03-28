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

[ ! `which sponge` ]	&& sudo apt install moreutils
[ ! `which ssconvert` ] && sudo apt install gnumeric

_NIVEAU_TRACE=1
f_check_params $#

f_trace 2 "Begining $0"
_MONTH="$1"
_YEAR=`date +%Y`
_YM="${_YEAR}-${_MONTH}"

# Data from inverter
cd data && find . -name "*.xls" > conversion.txt; cd - 1>/dev/null
while IFS= read -r "f" ; do
	filename="${f%.*}"
	if [ ! -f "csv/${filename}.csv" ]; then
		ssconvert -v data/"${filename}".xls csv/"${filename}".csv
		cat csv/"${filename}".csv | cut -d',' -f2- | sponge csv/"${filename}".csv
	fi
done < data/conversion.txt
rm csv/all.csv 2>/dev/null
sort -k1 -u csv/${_YEAR}${_MONTH}*.csv > csv/all.csv

# Data from Enedis
cat data/mes-puissances-atteintes-30min-*.csv > csv/enedis.csv
# Conversion en ASCII
_ICONV_FROM=`file -i -b csv/enedis.csv | awk -F'charset=' '{ print $2 }'`
iconv -f $_ICONV_FROM -t ASCII//TRANSLIT csv/enedis.csv | sponge csv/enedis.csv

# Compute and plot
_DAY=${_YM}-01
_DAYE=${_YM}-31
while [ ${_DAY//-/$''} -le ${_DAYE//-/$''} ]; do
	echo "Day $_DAY :" 
	./calculate_onduleur.sh $_DAY
	./calculate_enedis.sh $_DAY
	./gnuplot_onduleur.sh $_DAY &
	./gnuplot_onduleur_enedis.sh $_DAY &
	./gnuplot2_onduleur.sh $_DAY &
	./gnuplot3_onduleur.sh $_DAY &
	./gnuplot4_onduleur.sh $_DAY &
	_DAY=`date -I -d "$_DAY + 1 day"`
done
wait

# Purge
rm -f csv/all.csv 2>/dev/null
