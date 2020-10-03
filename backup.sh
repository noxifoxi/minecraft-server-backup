#!/bin/bash

# ======== #
#  Config  #
# ======== #
cd /home/minecraft/ # change working directory where the scripts are located
sleep=10 # wait time for the backup in seconds after the anouncement
stop_server=0 # 0-1
source_path="/home/minecraft/server/*"
backup_path="/media/backupdrive/mc-backup/"
screen_name="minecraft" # name of the screen the server is running
start_script="start.sh" # "autostart.sh -i" also works (if you you use the extra features)
start_script_execute_in_screen=1 # for autostart.sh and similar set this to 0
compression=9 # 0-9
create_latest=1 # create link to the latest backup (0-1)
create_lock=1 # create lock file for autostart.sh (0-1)
keep_backup_days=7 # delete backups older than this in days (0 disables this feature)


send_screen(){
	screen -S $screen_name -p 0 -X stuff "$1^M"
}


# create lock file
[ $create_lock == 1 ] && touch backup.lock


# ============= #
#  Anouncement  #
# ============= #
approx_execution_time=5
# get the previous execution time
[ -f "backup.time" ] && approx_execution_time=$(<backup.time)

send_screen "say §cBackup in $sleep seconds..."
if [ $stop_server == 1 ]; then
	send_screen "say §eThe server will shutdown for ~$approx_execution_time minutes!"
else
	send_screen "say §eThe server will probably lag for ~$approx_execution_time minutes!"
fi

# wait for the configured amount of seconds
sleep $sleep


# ==================== #
#  Backup preparation  #
# ==================== #

# measure time
start_time=`date +%s`

if [ $stop_server == 0 ]; then
# disable auto saving and save world
	send_screen "save-off^Msave-all^Msay §cWorld backup in progress..."
else
# stop the server and save world
	send_screen "stop"
fi
# give server shutdown and world saving a bit of time
sleep 1


# ======== #
#  Backup  #
# ======== #
filename=$backup_path"$(date +%Y-%m-%d-%H%M%S).7z"
if [[ "$1" != "-s" ]]; then
	7z a -mx=$compression -bsp0 -bso0 -y $filename $source_path > /dev/null
	[ $create_latest == 1 ] && ln -f $filename $backup_path"latest/backup.7z"
else
	sleep 10
fi


# ============= #
#  Post backup  #
# ============= #

if [ $stop_server == 1 ]; then
	# start  the server
	if [[ $start_script_execute_in_screen == 1 ]]; then
		send_screen "./$start_script"
	else
		./$start_script
	fi
else
# enable auto saving again
	send_screen "save-on^Msay §aBackup done!"
fi

# delete old backups
if [ $keep_backup_days -gt 0 ]; then
	# convert days into seconds
	keep_backup_days=$(( $keep_backup_days * 86400 ))
	current_time=`date +%s`
	for entry in "$backup_path"*.7z
	do
		if [ $(( $current_time - $(stat -c "%Y" "$entry") )) -gt $keep_backup_days ]; then
			rm $entry
		fi
	done
fi

# delete lock file
[ $create_lock == 1 ] && rm backup.lock

# save execution time in minutes
end_time=`date +%s`
if [[ "$1" != "-s" ]]; then
	echo $(( ((end_time-start_time)/60)+1 )) > backup.time
fi
