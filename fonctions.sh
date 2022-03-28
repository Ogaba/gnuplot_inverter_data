#!/bin/bash
#* h***************************************************************************
# Common Gnuplot Functions and various fonctions
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
VERSION=1.1.1

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

# Common GnuPlot Functions

f_set_terminal_png()
{ # Common header to plot in PNG graphics
 V_SIZE=40
 H_SIZE=120
 H_SIZE2=`echo "$H_SIZE + 8" | bc`
 echo "gnuplot<<EOF" > $_TMP
 echo -n "set terminal png size $1,$2 " >> $_TMP
 echo -n "$H_SIZE2 " >> $_TMP
 echo "$V_SIZE + 8" | bc >> $_TMP
}

f_set_margins()
{
 echo "set lmargin at screen 0.1" >> $_TMP
 echo "set rmargin at screen 0.9" >> $_TMP
 echo "set bmargin at screen 0.1" >> $_TMP
 echo "set tmargin at screen 0.9" >> $_TMP
}

f_set_transparency_colors()
{
### add colors by name with transparency
echo "reset session" >> $_TMP

# must be existing gnuplot color names
echo "ColorNames = \"white black dark-grey red web-green web-blue dark-magenta dark-cyan dark-orange dark-yellow royalblue goldenrod dark-spring-green purple steelblue dark-red dark-chartreuse orchid aquamarine brown yellow turquoise grey0 grey10 grey20 grey30 grey40 grey50 grey60 grey70 grey grey80 grey90 grey100 light-red light-green light-blue light-magenta light-cyan light-goldenrod light-pink light-turquoise gold green dark-green spring-green forest-green sea-green blue dark-blue midnight-blue navy medium-blue skyblue cyan magenta dark-turquoise dark-pink coral light-coral orange-red salmon dark-salmon khaki dark-khaki dark-goldenrod beige olive orange violet dark-violet plum dark-plum dark-olivegreen orangered4 brown4 sienna4 orchid4 mediumpurple3 slateblue1 yellow4 sienna1 tan1 sandybrown light-salmon pink khaki1 lemonchiffon bisque honeydew slategrey seagreen antiquewhite chartreuse greenyellow gray light-gray light-grey dark-gray slategray gray0 gray10 gray20 gray30 gray40 gray50 gray60 gray70 gray80 gray90 gray100\"" >> $_TMP

echo "ColorValues = \"0xffffff 0x000000 0xa0a0a0 0xff0000 0x00c000 0x0080ff 0xc000ff 0x00eeee 0xc04000 0xc8c800 0x4169e1 0xffc020 0x008040 0xc080ff 0x306080 0x8b0000 0x408000 0xff80ff 0x7fffd4 0xa52a2a 0xffff00 0x40e0d0 0x000000 0x1a1a1a 0x333333 0x4d4d4d 0x666666 0x7f7f7f 0x999999 0xb3b3b3 0xc0c0c0 0xcccccc 0xe5e5e5 0xffffff 0xf03232 0x90ee90 0xadd8e6 0xf055f0 0xe0ffff 0xeedd82 0xffb6c1 0xafeeee 0xffd700 0x00ff00 0x006400 0x00ff7f 0x228b22 0x2e8b57 0x0000ff 0x00008b 0x191970 0x000080 0x0000cd 0x87ceeb 0x00ffff 0xff00ff 0x00ced1 0xff1493 0xff7f50 0xf08080 0xff4500 0xfa8072 0xe9967a 0xf0e68c 0xbdb76b 0xb8860b 0xf5f5dc 0xa08020 0xffa500 0xee82ee 0x9400d3 0xdda0dd 0x905040 0x556b2f 0x801400 0x801414 0x804014 0x804080 0x8060c0 0x8060ff 0x808000 0xff8040 0xffa040 0xffa060 0xffa070 0xffc0c0 0xffff80 0xffffc0 0xcdb79e 0xf0fff0 0xa0b6cd 0xc1ffc1 0xcdc0b0 0x7cff40 0xa0ff20 0xbebebe 0xd3d3d3 0xd3d3d3 0xa0a0a0 0xa0b6cd 0x000000 0x1a1a1a 0x333333 0x4d4d4d 0x666666 0x7f7f7f 0x999999 0xb3b3b3 0xcccccc 0xe5e5e5 0xffffff\"" >> $_TMP

echo "myColor(c) = (idx=NaN, sum [i=1:words(ColorNames)] (c eq word(ColorNames,i) ? idx=i : idx), word(ColorValues,idx))" >> $_TMP

# add transparency (alpha) a=0 to 255 or 0x00 to 0xff
echo "myTColor(c,a) = sprintf(\"0x%x%s\",a, myColor(c)[3:])" >> $_TMP
}

f_set_styleline()
{
# $1 : point size
echo "set style line 2 lt rgb myTColor(\"red\",0xee) lw $1" >> $_TMP
echo "set style line 3 lt rgb myTColor(\"orange\",0xee) lw $1" >> $_TMP
echo "set style line 4 lt rgb myTColor(\"yellow\",0xee) lw $1" >> $_TMP
echo "set style line 5 lt rgb myTColor(\"green\",0xee) lw $1" >> $_TMP
echo "set style line 6 lt rgb myTColor(\"cyan\",0xee) lw $1" >> $_TMP
echo "set style line 7 lt rgb myTColor(\"blue\",0xee) lw $1" >> $_TMP
echo "set style line 8 lt rgb myTColor(\"violet\",0xee) lw $1" >> $_TMP
echo "set style line 9 lt rgb myTColor(\"skyblue\",0xee) lw $1" >> $_TMP
echo "set style line 10 lt rgb myTColor(\"turquoise\",0xee) lw $1" >> $_TMP
echo "set style line 11 lt rgb myTColor(\"magenta\",0xee) lw $1" >> $_TMP
echo "set style line 12 lt rgb myTColor(\"olive\",0xee) lw $1" >> $_TMP
echo "set style line 13 lt rgb myTColor(\"beige\",0xee) lw $1" >> $_TMP
echo "set style line 14 lt rgb myTColor(\"orchid\",0xee) lw $1" >> $_TMP
echo "set style line 15 lt rgb myTColor(\"salmon\",0xee) lw $1" >> $_TMP
echo "set style line 16 lt rgb myTColor(\"seagreen\",0xee) lw $1" >> $_TMP
echo "set style line 17 lt rgb myTColor(\"pink\",0xee) lw $1" >> $_TMP
echo "set style line 18 lt rgb myTColor(\"gray\",0xee) lw $1" >> $_TMP
echo "set style line 19 lt rgb myTColor(\"black\",0xee) lw $1" >> $_TMP
}

f_set_linetype()
{
# $1 : linetype
# $2 : point size
case $1 in
	2)  echo "set linetype 2  linecolor \"red\" lw $2" >> $_TMP;;
	4)  echo "set linetype 4  linecolor \"yellow\" lw $2" >> $_TMP;;
	5)  echo "set linetype 5  linecolor \"green\" lw $2" >> $_TMP;;
	8)  echo "set linetype 8  linecolor \"violet\" lw $2" >> $_TMP;;
	10) echo "set linetype 11 linecolor \"turquoise\" lw $2" >> $_TMP;;
	11) echo "set linetype 11 linecolor \"magenta\" lw $2" >> $_TMP;;
	*)  echo "set linetype 19 linecolor \"black\" lw $2" >> $_TMP;;
esac
}

f_set_multiplot()
{
echo "set multiplot" >> $_TMP
}

f_set_title()
{
echo "set title \"$1\"" >> $_TMP
}

f_set_xlabel()
{
echo "set xlabel \"$1\"" >> $_TMP
}

f_set_datafile_sep()
{
echo "set datafile separator \"$1\"" >> $_TMP
}

f_set_xdata_time()
{
echo "set xdata time" >> $_TMP
}

f_set_timefmt()
{
echo "set timefmt \"%Y-%m-%d %H:%M:%S\"" >> $_TMP
}

f_set_format_x()
{
echo "set format x '%H'" >> $_TMP
}

f_set_tics_scale()
{
echo "set tics scale $1" >> $_TMP
}

f_set_grid()
{
echo "set grid" >> $_TMP
}

f_set_yrange()
{
echo "set yrange [${1}:${2}]" >> $_TMP
}

f_set_y2range() 
{ 
echo "set y2range [${1}:${2}]" >> $_TMP
}

f_set_ytics()
{
echo "set ytics nomirror" >> $_TMP
}

f_set_y2tics()
{
echo "set y2tics nomirror" >> $_TMP
}

f_set_key()
{
echo "set key $1" >> $_TMP
}

f_set_ylabel()
{
echo "set ylabel \"$1\"" >> $_TMP
}

f_set_y2label()
{
echo "set y2label \"$1\"" >> $_TMP
}
