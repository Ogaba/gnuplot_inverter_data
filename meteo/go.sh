#!/bin/bash
#* h***************************************************************************
# Generate csv from openweathermap.org data collected.
#
# Author...... : Olivier Gabathuler
# Created..... : 2022-03-29 OGA V1.0.0
# Modified.... : 
# Notes....... :
#
# Miscellaneous.
# --------------
# - Version: don't forget to update VERSION (look for VERSION below)!
# - Exit codes EXIT_xxxx are for internal use (see below).
#
#**************************************************************************h *#
# Provides tocsv and fromcsv functions
. ./fonctions.sh

# Main

# Version
VERSION=1.0.0

[ ! `which jq` ] && sudo apt install jq
[ ! `which sponge` ] && sudo apt install moreutils

_NIVEAU_TRACE=1
f_check_params $#

f_trace 2 "Begining $0"
_MONTH="$1"
_YEAR=`date +%Y`
_YM="${_YEAR}${_MONTH}"

mkdir csv 2>/dev/null

f_trace 1 "Convert JSON data from openweathermap.org to CSV"
cd data && find . -name "${_YM}*.json" > conversion.txt; cd - 1>/dev/null
while IFS= read -r "f" ; do
	filename="${f%.*}"
	if [ ! -f "csv/${filename}.csv" ]; then
		echo "# latitude,longitude,timezone,date,temperature,humidity,description,clouds,visibility" > csv/"${filename}".csv
		cat data/"${filename}".json |\
		# Convert JSON data from openweathermap.org to CSV
		# with weather API call
		# visibility.value Visibility, meter. The maximum value of the visibility is 10km
		jq -r '[.coord .lat,.coord .lon,.timezone,.dt,.main .temp,.main .humidity,.weather[] .description,.clouds .all,.visibility] | @csv' |\
		# or with onecall API call
		# jq -r '[.current .dt,.current .temp,.current .humidity,.current .uvi,.current .clouds,.current .visibility] | @csv'
		# Convert UNIX timestamp $4 in seconds since 1970 to %Y-%m-%d %H:%M:%S format with awk
		awk -F',' 'sub(/[0-9]{10}/,strftime("%Y-%m-%d %H:%M:%S", $4))1' >> csv/"${filename}".csv
	else
		cat data/"${filename}".json |\
		jq -r '[.coord .lat,.coord .lon,.timezone,.dt,.main .temp,.main .humidity,.weather[] .description,.clouds .all,.visibility] | @csv' |\
		awk -F',' 'sub(/[0-9]{10}/,strftime("%Y-%m-%d %H:%M:%S", $4))1' >> csv/"${filename}".csv
		sort -u csv/"${filename}".csv | sponge csv/"${filename}".csv
	fi
done < data/conversion.txt

# Purge
