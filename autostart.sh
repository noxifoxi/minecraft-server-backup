#!/bin/bash

# don't execute script if backup is in progress
[ -f backup.lock ] && exit 0


# ======== #
#  Config  #
# ======== #
server_jar="fabric-server-launch.jar" # server jar to monitor
screen_name="minecraft" # name of the screen the server is running
dir="minecraft" # cd the screen session in this directory
start_script="start.sh"


# =========== #
#  Autostart  #
# =========== #
# check if minecraft server is not running
if ! pgrep -a java | grep -q $server_jar; then
	# check if screen session does not exists
	if ! screen -list | grep -q $screen_name; then
		# create screen
		screen -dmS $screen_name

		# change directory
		screen -S $screen_name -p 0 -X stuff "cd $dir^M"
	fi

	# start server
	screen -S $screen_name -p 0 -X stuff "./$start_script^M"
fi
