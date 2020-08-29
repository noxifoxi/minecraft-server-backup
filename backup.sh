#!/bin/sh
# variables
sleep=10
backup_path="./backup/"

# anouncement
screen -S minecraft -p 0 -X stuff "say §cBackup in $sleep seconds...^Msay §eThe server will lag!^M"
sleep $sleep

# disable auto saving and save world
screen -S minecraft -p 0 -X stuff "save-off^Msave-all^Msay §cWorld backup in progress...^M"
# give world saving a bit of time
sleep 1

# backup
7z a -mx=9 -bsp0 -bso0 -y "$backup_path$(date +%Y-%m-%d-%H%M%S).7z" * > /dev/null

# enable auto saving again
screen -S minecraft -p 0 -X stuff "save-on^Msay §aBackup done!^M"
