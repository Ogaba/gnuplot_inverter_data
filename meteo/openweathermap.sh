#!/bin/bash
#* h***************************************************************************
# Collect open meteo data from openweathermap.org
#
# Author...... : Olivier Gabathuler
# Created..... : 2022-03-28 OGA V1.0.0
# Modified.... : 
# Notes....... :
#
# Miscellaneous.
# --------------
# - Version: don't forget to update VERSION (look for VERSION below)!
# - Exit codes EXIT_xxxx are for internal use (see below).
#
#**************************************************************************h *#

# Main
[ `which jq` ] || sudo apt  install jq

# Version
VERSION=1.0.0

# Current day
_DATE=`date +%Y-%m-%d`

# lat and lon are for house
curl "https://api.openweathermap.org/data/2.5/onecall?lat=50.649923&lon=3.129666&timezone=Europe/Paris&appid=73a8086daf03642a83158b947745277d&units=metric" | jq >> ~/developpement/meteo/${_DATE}_maison_villeneuve
