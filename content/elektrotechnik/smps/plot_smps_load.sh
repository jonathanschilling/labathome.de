#!/usr/bin/gnuplot
# Plotten von Graphen mit Output
# B. Tadsen, J. Schilling
#====================================

# Encoding (the one and only)
set encoding utf8

# Use the postscript eps version because it uses the chosen font for everything but symbols
# so Greek letters look really nice!
set terminal postscript eps enhanced color size 8.8cm,6cm font "TeXGyreHeros-Regular,19.2" \
    fontfile "/usr/share/texmf/fonts/type1/public/tex-gyre/qhvr.pfb" #\
    #fontfile add "/usr/share/fonts/X11/Type1/Symbol.pfb" lw 1.5
# Older version used other terminal(options):
#set terminal epscairo size 8.8cm,6cm enhanced font "Liberation Sans,12" lw 4
#set terminal postscript eps enhanced color size 8.8cm,24cm font "Helvetica,19.2" lw 1.5

# Output is first local:
set output "./smps_load.eps"

# voltage source u0 with internal resistance r
model(x)=u0-r*x
u0=30
r=10

fit model(x) 'Belastungskurve.dat' u ($1/$2):1 every ::0::6 via u0,r

# Design configurations
set xlabel "load current / A"
set ylabel "loaded output / V"
set format x "%g"
set format y "%g"
set grid

# Plotting data to the file
plot 'Belastungskurve.dat' u ($1/$2):1 w lp title "measurement" lc rgb "red" lw 2 ps 2,\
     model(x) title "R_i=9.3 Ohm" lc rgb "blue" lw 2
