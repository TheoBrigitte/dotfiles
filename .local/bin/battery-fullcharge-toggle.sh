#!/bin/bash

set -eu

# Check current battery charge threshold with the following command:
# sudo tlp-stat --battery

notify_send() {
    #Detect the name of the display in use
    local display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"

    #Detect the user using such display
    local user=$(who | grep '('$display')' | awk '{print $1}' | head -n 1)

    #Detect the id of the user
    local uid=$(id -u $user)

    sudo -u $user DISPLAY=$display DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send "$@"
}

current_charge_threshold=$(cat /sys/class/power_supply/BAT0/charge_control_end_threshold)

if [ $current_charge_threshold -eq 100 ]; then
    pkexec tlp setcharge
    notify_send "Battery care enabled"
else
    pkexec tlp fullcharge
    notify_send "Battery care disabled"
fi
