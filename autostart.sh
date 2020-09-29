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
disable_joining=0 # EXPERIMENTAL: disable joining for <amount> seconds by renaming the whitelist (includes the time the server needs to start, 0 to disable this feature)
start_script="start.sh"


send_screen(){
	screen -S $screen_name -p 0 -X stuff "$1^M"
}


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
		send_screen "cd $dir"
	fi

	# disable joining if feature is enabled
	[ $disable_joining -gt 0 ] && mv -f whitelist.json whitelist.json.bak
	
	# start server
	send_screen "./$start_script"

	# re-enable joining if feature is enabled
	if [ $disable_joining -gt 0 ]; then
		sleep $disable_joining
		mv -f whitelist.json.bak whitelist.json
		send_screen "whitelist reload"
	fi
fi
