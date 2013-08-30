#!/bin/sh
# USAGE: wifi.sh <interface>
iwconfig $1 | grep ESSID | perl -E '<> =~ /"(.+)"/; print $1 // "n/a"'
