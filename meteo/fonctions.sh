#!/bin/bash
#* h***************************************************************************
# Common JSON data manipulation functions
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
VERSION=1.0.0

f_trace()
# $1 : level
# $2 : message
{ # check and set
[ -z "$_NIVEAU_TRACE" ] && _NIVEAU_TRACE=1
if [ $1 -le $_NIVEAU_TRACE ]; then
        _NIVEAU_TRACE=$1
        DATEE=`date +'%Y-%m-%d %H:%M:%S'`
        printf "%s $_NIVEAU_TRACE %s\n" "$DATEE" "$2"
fi
}

f_check_params()
{
[ ! "$1" -eq 1 ] && f_trace 1 "Please give month of current year." && exit 1
}

# JSON functions

# JSON to CSV manipulations
# https://stackoverflow.com/questions/69230818/how-to-convert-arbitrary-nested-json-to-csv-with-jq-so-you-can-convert-it-back

function tocsv {
 jq -ncr --stream '
   (["# path", "value", "stringp"],
    (inputs | . + [.[1]|type=="string"]))
   | map( tostring|gsub("\"";"\"\"") | gsub("\n"; "\\n"))
   | "\"\(.[0])\",\"\(.[1])\",\(.[2])" 
' | tr -d '[]"'
}

# CSV to JSON manipulations
# https://stackoverflow.com/questions/69230818/how-to-convert-arbitrary-nested-json-to-csv-with-jq-so-you-can-convert-it-back
function fromcsv { 
    tail -n +2 | # first duplicate backslashes and deduplicate double-quotes
    jq -rR '"[\(gsub("\\\\";"\\\\") | gsub("\"\"";"\\\"") ) ]"' |
    jq -c '.[2] as $s 
           | .[0] |= fromjson 
           | .[1] |= if $s then . else fromjson end 
           | if $s == null then [.[0]] else .[:-1] end
             # handle newlines
           | map(if type == "string" then gsub("\\\\n";"\n") else . end)' |
    jq -n 'fromstream(inputs)'
}
