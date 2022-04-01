#!/bin/bash
#* h***************************************************************************
# Generate various data from inverter collected.
#
# Author...... : Olivier Gabathuler
# Created..... : 2022-03-14 OGA V1.0.0
# Modified.... : 2022-04-01 OGA V1.1.0
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
VERSION=1.1.0

[ ! `which sponge` ]	&& sudo apt install moreutils
[ ! `which ssconvert` ] && sudo apt install gnumeric

_NIVEAU_TRACE=1
f_check_params_go $#

f_trace 2 "Begining $0"
_MONTH="$1"
_YEAR=`date +%Y`
_YM="${_YEAR}-${_MONTH}"
_YM2="${_YEAR}${_MONTH}"

# Convert XLS data from inverter to CSV
echo "Conversion des fichiers xls issus de PowerWatch :"
cd data && find . -name "*.xls" > conversion.txt; cd - 1>/dev/null
while IFS= read -r "f" ; do
	filename="${f%.*}"
	ssconvert -v data/${filename}.xls csv/${filename}.csv
	[ $? -eq 0 ] && grep -h "$_YM" csv/"${filename}".csv >> csv/${_YM2}.csv || echo "Erreur de génération de csv/${_YM2}.csv !"
	[ $? -eq 0 ] && rm csv/${filename}.csv || echo "Erreur de recherche de $_YM dans csv/${filename}.csv !"
	[ $? -eq 0 ] && rm data/${filename}.xls || echo "Erreur de suppression de data/${filename}.xls !"
done < data/conversion.txt
sort -k2 -u csv/${_YM2}.csv | sponge csv/${_YM2}.csv

# Data from Enedis
cat data/mes-puissances-atteintes-30min-*.csv > csv/enedis.csv
# Conversion en ASCII
_ICONV_FROM=`file -i -b csv/enedis.csv | awk -F'charset=' '{ print $2 }'`
iconv -f $_ICONV_FROM -t ASCII//TRANSLIT csv/enedis.csv | sponge csv/enedis.csv

# Compute and plot except for current day (we don't have all data for current day)
_DAY=${_YM}-01
_DAYE=${_YM}-31
_CURDAY=`date +%Y%m%d`
while [ ${_DAY//-/$''} -le ${_DAYE//-/$''} ]; do
	if [ "${_DAY//-/$''}" -ne "$_CURDAY" ]; then
		echo "Day $_DAY :" 
		./calculate_onduleur.sh $_YM2 $_DAY
		./calculate_enedis.sh $_DAY
		./gnuplot_onduleur.sh $_YM2 $_DAY &
		./gnuplot_onduleur_enedis.sh $_YM2 $_DAY &
		./gnuplot2_onduleur.sh $_YM2 $_DAY &
		./gnuplot3_onduleur.sh $_YM2 $_DAY &
		./gnuplot4_onduleur.sh $_YM2 $_DAY &
		#./gnuplot_meteo.sh $_DAY &
		#./gnuplot_soleil_meteo.sh $_DAY &
	else
		echo "Day $_DAY not finished."
	fi
	_DAY=`date -I -d "$_DAY + 1 day"`
done
wait

# Purge
