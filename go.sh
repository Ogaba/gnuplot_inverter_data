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
# Specific Gnuplot functions
. ./fonctions.sh

# Main

# Version
VERSION=1.1.0

[ ! `which pcregrep` ]	&& sudo apt install pcregrep
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
echo "Conversion des fichiers xls issus de PowerWatch en csv :"
cd data && find . -name "${_YM2}*.xls" > conversion.txt; cd - 1>/dev/null
while IFS= read -r "_F" ; do
	_FILE="${_F%.*}"
	ssconvert -v data/${_FILE}.xls csv/${_FILE}.csv
	pcregrep -o "(20[2-9][0-9]\-[0-1][0-9])" csv/${_FILE}.csv | uniq | while read _YYYYMM; do
		_YYYYMM2=`echo $_YYYYMM | tr -d '-'`
		grep -h "$_YYYYMM" csv/"${_FILE}".csv >> csv/${_YYYYMM2}.csv || echo "Erreur de génération de csv/${_YYYYMM2}.csv !"
	done
	[ $? -eq 0 ] && rm csv/${_FILE}.csv || echo "Erreur de suppression de csv/${_FILE}.csv !"
	[ $? -eq 0 ] && rm data/${_FILE}.xls || echo "Erreur de suppression de data/${_FILE}.xls !"
done < data/conversion.txt
[ -f csv/${_YM2}.csv ] && sort -k2 -u csv/${_YM2}.csv | sponge csv/${_YM2}.csv

# Data from Enedis
echo "Conversion des fichiers csv UTF-8 issus d'Enedis en csv ASCII :"
cat data/mes-puissances-atteintes-30min-*.csv > csv/enedis.csv
# Conversion en ASCII
_ICONV_FROM=`file -i -b csv/enedis.csv | awk -F'charset=' '{ print $2 }'`
iconv -f $_ICONV_FROM -t ASCII//TRANSLIT csv/enedis.csv | sponge csv/enedis.csv

# Compute and plot except for current day (we don't have all data for current day)
echo "Calcul et construction des graphiques sauf pour le jour courant :"
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
		./gnuplot_meteo.sh $_DAY &
		./gnuplot_soleil_meteo.sh $_DAY &
	else
		echo "Day $_DAY not finished."
	fi
	_DAY=`date -I -d "$_DAY + 1 day"`
done
wait

# Purge
