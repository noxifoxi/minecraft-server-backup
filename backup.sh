#!/bin/bash

# ======== #
#  Config  #
# ======== #
sleep=10 # wait time for the backup in seconds after the anouncement
stop_server=0 # 0-1
source_path="/home/minecraft/server/*"
backup_path="/media/backupdrive/mc-backup/"
screen_name="minecraft" # name of the screen the server is running
compression=9 # 0-9
create_latest=1 # 0-1


# ============= #
#  Anouncement  #
# ============= #
screen -S $screen_name -p 0 -X stuff "say §cBackup in $sleep seconds...^M"
if [ $stop_server == 1 ]; then
	screen -S $screen_name -p 0 -X stuff "say §eThe server will shutdown for ~5 minutes!^M"
else
	screen -S $screen_name -p 0 -X stuff "say §eThe server will lag!^M"
fi

# wait for the configured amount of seconds
sleep $sleep


# ==================== #
#  Backup preparation  #
# ==================== #
if [ $stop_server == 0 ]; then
	# disable auto saving and save world
	screen -S $screen_name -p 0 -X stuff "save-off^Msave-all^Msay §cWorld backup in progress...^M"

	# give world saving a bit of time
	sleep 1
fi

if [ $stop_server == 1 ]; then
	screen -S $screen_name -p 0 -X stuff "stop^M"

	# give server shutdown and world saving a bit of time
	sleep 1
fi


# ======== #
#  Backup  #
# ======== #
filename=$backup_path"$(date +%Y-%m-%d-%H%M%S).7z"
7z a -mx=$compression -bsp0 -bso0 -y $filename $source_path > /dev/null
if [ $create_latest == 1 ]; then
	ln -f $filename $backup_path"latest/backup.7z"
fi


# ============= #
#  Post backup  #
# ============= #
if [ $stop_server == 1 ]; then
	# starting the server
	screen -S $screen_name -p 0 -X stuff "./start.sh^M"
else
	# enable auto saving again
	screen -S $screen_name -p 0 -X stuff "save-on^Msay §aBackup done!^M"
fi
