#!/bin/bash

# This is a demo of the installer for config files.
# The CalmLink configs are designed to copy to /usr/local/calmlink/.
# (You will have to make that directory and fix owner and permissions.)
# Copy this file push-demo.bash to some other filename,
# and edit that file to have your callsign and EchoLink password.
# Then every time you edit your config files,
# rerun this command to install them, and restart svxlink.

set -ex

# SET THESE FIELDS.  Do not use semicolons.
password='open-sesame'
callsign='W1AW-R'
identify='W1AW'
repeater='Gotham Repeater'
subtitle='G0THM/R www.gotham.demo'
timeout='20'

function copy() {
sed \
  -e "s;%password%;$password;" \
  -e "s;%callsign%;$callsign;" \
  -e "s;%identify%;$identify;" \
  -e "s;%repeater%;$repeater;" \
  -e "s;%subtitle%;$subtitle;" \
  -e "s;%timeout%;$timeout;" \
  < "$1" > "$2"
}

rm -f /usr/local/calmlink/*
for x in *.conf *.tcl
do
  copy "$x" "/usr/local/calmlink/$x"
done
