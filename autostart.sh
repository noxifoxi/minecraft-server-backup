#!/bin/bash

# ======== #
#  Config  #
# ======== #
cd /home/minecraft/ # change working directory where the scripts are located

# don't execute script if backup is in progress
[ -f backup.lock ] && exit 0

server_jar="fabric-server-launch.jar" # server jar to monitor
screen_name="minecraft" # name of the screen the server is running
dir="." # cd the screen session in this directory ("." if no change)
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

		# wait for the screen session to get created?
		sleep 2

		# change directory
		screen -S $screen_name -p 0 -X stuff "cd $dir^M"
	fi

	# start server
	screen -S $screen_name -p 0 -X stuff "./$start_script^M"
fi
