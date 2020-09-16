#!/bin/bash

# ======== #
#  Config  #
# ======== #
sleep=10 # wait time for the backup in seconds after the anouncement
stop_server=0 # 0-1
source_path="/home/minecraft/server/*"
backup_path="/media/backupdrive/mc-backup/"
screen_name="minecraft" # name of the screen the server is running
start_script="start.sh"
compression=9 # 0-9
create_latest=1 # create link to the latest backup (0-1)
create_lock=1 # create lock file for autostart.sh (0-1)


# create lock file
[ $create_lock == 1 ] && touch backup.lock


# ============= #
#  Anouncement  #
# ============= #
approx_execution_time=5
# get the previous execution time
[ -f "backup.time" ] && approx_execution_time=$(<backup.time)

screen -S $screen_name -p 0 -X stuff "say §cBackup in $sleep seconds...^M"
if [ $stop_server == 1 ]; then
	screen -S $screen_name -p 0 -X stuff "say §eThe server will shutdown for ~$approx_execution_time minutes!^M"
else
	screen -S $screen_name -p 0 -X stuff "say §eThe server will probably lag for ~$approx_execution_time minutes!^M"
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
	screen -S $screen_name -p 0 -X stuff "save-off^Msave-all^Msay §cWorld backup in progress...^M"
else
# stop the server and save world
	screen -S $screen_name -p 0 -X stuff "stop^M"
fi
# give server shutdown and world saving a bit of time
sleep 1


# ======== #
#  Backup  #
# ======== #
filename=$backup_path"$(date +%Y-%m-%d-%H%M%S).7z"
7z a -mx=$compression -bsp0 -bso0 -y $filename $source_path > /dev/null
[ $create_latest == 1 ] && ln -f $filename $backup_path"latest/backup.7z"


# ============= #
#  Post backup  #
# ============= #
if [ $stop_server == 1 ]; then
# start  the server
	screen -S $screen_name -p 0 -X stuff "./$start_script^M"
else
# enable auto saving again
	screen -S $screen_name -p 0 -X stuff "save-on^Msay §aBackup done!^M"
fi

# delete lock file
[ $create_lock == 1 ] && rm backup.lock

# save execution time in minutes
end_time=`date +%s`
echo $(( ((end_time-start_time)/60)+1 )) > backup.time
