#!/bin/bash

# ============================================================
# IMPORTANT  IMPORTANT  IMPORTANT  IMPORTANT  IMPORTANT
# ============================================================
# 
# Requires gcp, which is a replacement for traditional "cp"
# Can be installed using:
# 
# $ brew install coreutils

# ============================
# usage
# ============================
# 
# $ cd /scripts/rsync
# $ ./backup.sh		(no argument, will do whatever needs to be done based on previous backup session.)
# $ ./backup.sh -h 	(help) Shows this usage info
# $ ./backup.sh -a 	(generate archive)
# $ ./backup.sh -d 	(run daily)
# $ ./backup.sh -w 	(run weekly)
# $ ./backup.sh -m 	(run monthly)

# ============================
# options
# ============================
# 
# Locations
# ----------------------------
# NO TRAILING SLASH
SRC_PATH="/Volumes/Drives"
BACKUP_PATH="/Volumes/BU12/backups"
EXCLUDES="/scripts/rsync/excludes.txt"

# How many to keep
# ----------------------------
# Expressed in units relative to itself
# e.g. 
# 		HOURLY_KEEPS = hours to keep
# 		DAILY_KEEPS = days to keep
#		WEEKLY_KEEPS = weeks to keep
#		MONTHLY_KEEPS = months to keep
# 
HOURLY_KEEPS=24
DAILY_KEEPS=7
WEEKLY_KEEPS=4
MONTHLY_KEEPS=12

# ========================================================
# ========================================================
# DO NOT EDIT BELOW HERE
# ========================================================
# ========================================================

# =========================
# Setup
# =========================

# NO TRAILING SLASH
HOURLY_PATH=$BACKUP_PATH"/hourly"
DAILY_PATH=$BACKUP_PATH"/daily"
WEEKLY_PATH=$BACKUP_PATH"/weekly"
MONTHLY_PATH=$BACKUP_PATH"/monthly"
ARCHIVE_PATH=$BACKUP_PATH"/archive"

# set the one you want to be default (when not flag on run) to 1, and others to 0
DO_HOURLY=0
DO_DAILY=0
DO_WEEKLY=0
DO_MONTHLY=0
DO_ARCHIVE=0

# These are files without extensions
STORE_DID_HOURLY=$BACKUP_PATH"/_LAST_HOURLY"
STORE_DID_DAILY=$BACKUP_PATH"/_LAST_DAILY"
STORE_DID_WEEKLY=$BACKUP_PATH"/_LAST_WEEKLY"
STORE_DID_MONTHLY=$BACKUP_PATH"/_LAST_MONTHLY"


# =========================
# Only run when backup drive and backup folder(s) exist.
# =========================

if [ ! -d "$SRC_PATH" ] || [ ! -d "$BACKUP_PATH" ]; then
	exit 0;
fi

# =========================
# Create Necessary File and Folders
# =========================

if ! [ -f "$STORE_DID_HOURLY" ]; then
touch "$STORE_DID_HOURLY"
fi;

if ! [ -f "$STORE_DID_DAILY" ]; then
touch "$STORE_DID_DAILY"
fi;

if ! [ -f "$STORE_DID_WEEKLY" ]; then
touch "$STORE_DID_WEEKLY"
fi;

if ! [ -f "$STORE_DID_MONTHLY" ]; then
touch "$STORE_DID_MONTHLY"
fi;

DID_HOURLY=`cat $STORE_DID_HOURLY`

DID_DAILY=`cat $STORE_DID_DAILY`

DID_WEEKLY=`cat $STORE_DID_WEEKLY`

DID_MONTHLY=`cat $STORE_DID_MONTHLY`


# make HOURLY_PATH & DAILY_PATH folders (if not exist)
if ! [ -d "$BACKUP_PATH" ]; then
mkdir "$BACKUP_PATH"
fi;
 
if ! [ -d "$HOURLY_PATH" ]; then
mkdir "$HOURLY_PATH"
fi; 

if ! [ -d "$DAILY_PATH" ]; then
mkdir "$DAILY_PATH"
fi; 

if ! [ -d "$WEEKLY_PATH" ]; then
mkdir "$WEEKLY_PATH"
fi;

if ! [ -d "$MONTHLY_PATH" ]; then
mkdir "$MONTHLY_PATH"
fi;
 
if ! [ -d "$ARCHIVE_PATH" ]; then
mkdir "$ARCHIVE_PATH"
fi;

# ============================
# parse options 
# ============================
usage() { echo -e "
========================
usage:
========================
   backup.sh -h (help) Shows this usage info
   backup.sh -a (generate archive)
   backup.sh -d (run daily)
   backup.sh -w (run weekly)
   backup.sh -m (run monthly)
   backup.sh (no argument, will do whatever needs to be done based on previous backup session.)

"; exit 0; }

#[ $# -eq 0 ] && usage
while getopts "ahdwmn" arg; do
  case $arg in
	a)
      DO_ARCHIVE=1
      ;;
    o)
      DO_HOURLY=1
      ;;
    h)
      usage
      exit 0
      ;;
    d)
      DO_DAILY=1
      ;;
	w)
      DO_WEEKLY=1
      ;;
	m)
      DO_MONTHLY=1
      ;;
	#*)
    #  DO_ARCHIVE=1
    #  ;;
    #*)
    #  usage
    #  exit 0
    #  ;;
  esac
done; 


# ==========================
# What to do?
# ==========================

DATE=`date "+%y%m%d-%H%M%S"` 
DATE_NICE=`date "+%y-%m-%d %H:%M"` 

# the - hyphen means "no zero padding" e.g. 04 to 4
DATE_HOUR=`date "+%-H"`
DATE_DAY=`date "+%-d"`

# Seconds since 1970. Used to automatically run things that need to be done.
STAMP=`date "+%s"`


# seconds in a hour 	3600
# seconds in a day 		86164
# seconds in a week 	604800
# seconds in a month 	2592000

# knock off 50 seconds on each
NEXT_HOUR=$((DID_HOURLY + 3550))
NEXT_DAY=$((DID_DAILY + 86100))
NEXT_WEEK=$((DID_WEEKLY + 604750))
NEXT_MONTH=$((DID_MONTHLY + 2591950))

# ---------------
# TESTING TIMES
# ---------------
# run this over-night
# NEXT_HOUR=$((DID_HOURLY + 3550))
# NEXT_DAY=$((DID_DAILY + 4550))
# NEXT_WEEK=$((DID_WEEKLY + 5550))
# NEXT_MONTH=$((DID_MONTHLY + 6550))

# run this now, and wait 5 seconds between re-running. 
# But do this test without running rsync e.g. check.sh.
# NEXT_HOUR=$((DID_HOURLY + 5))
# NEXT_DAY=$((DID_DAILY + 10))
# NEXT_WEEK=$((DID_WEEKLY + 15))
# NEXT_MONTH=$((DID_MONTHLY + 20))

if (( STAMP > NEXT_HOUR )); then
	
	DO_HOURLY=1
	
	if (( STAMP > NEXT_DAY )); then
		DO_DAILY=1
	fi
	
	if (( STAMP > NEXT_WEEK )); then
		DO_WEEKLY=1
		DO_ARCHIVE=1
	fi
	
	if (( STAMP > NEXT_MONTH )); then
		DO_MONTHLY=1
	fi

fi

if [ $DO_ARCHIVE = 1 ]; then
	DO_HOURLY=1
fi 


# =========================
# TESTING
# =========================
# SRC_PATH="/Users/bob/Desktop/wood"
# BACKUP_PATH="/Volumes/BU11/test"
# DO_ARCHIVE=0
# DO_HOURLY=1
# DO_MONTHLY=0
# DO_WEEKLY=0

echo "----------------------"
echo $DATE_NICE

if [ $DO_HOURLY = 1 ]; then
echo "DO_HOURLY: "$DO_HOURLY
fi; 

if [ $DO_DAILY = 1 ]; then
echo "DO_DAILY: "$DO_DAILY
fi; 

if [ $DO_WEEKLY = 1 ]; then
echo "DO_WEEKLY: "$DO_WEEKLY
fi; 

if [ $DO_MONTHLY = 1 ]; then
echo "DO_MONTHLY: "$DO_MONTHLY
fi; 

if [ $DO_ARCHIVE = 1 ]; then
echo "DO_ARCHIVE: "$DO_ARCHIVE
fi; 


# Sleep for 1 minute to ensure drives have enough
# time to boot and be seen by the system after login.
# But do this after getting the date and determining 
# what we are to do.
sleep 1m

# =========================
# Create Folders
# =========================

# Create 0-n folders (if not exist)
# --- HOURLY 
for (( i=0; i<=$HOURLY_KEEPS-1; i++ ))
do  
   if ! [ -d "$HOURLY_PATH/$i" ]; then mkdir "$HOURLY_PATH/$i"; fi; 
done; 

# Remeber the last one
LAST_HOURLY=$((i-1))

# --- DAILY
for (( i=0; i<=$DAILY_KEEPS-1; i++ ))
do  
   if ! [ -d "$DAILY_PATH/$i" ]; then mkdir "$DAILY_PATH/$i"; fi; 
done; 

# Remeber the last one
LAST_DAILY=$((i-1))

# --- WEEKLY
for (( i=0; i<=$WEEKLY_KEEPS-1; i++ ))
do  
   if ! [ -d "$WEEKLY_PATH/$i" ]; then mkdir "$WEEKLY_PATH/$i"; fi; 
done; 

# Remeber the last one
LAST_WEEKLY=$((i-1))

# --- MONTHLY
for (( i=0; i<=$MONTHLY_KEEPS-1; i++ ))
do  
   if ! [ -d "$MONTHLY_PATH/$i" ]; then mkdir "$MONTHLY_PATH/$i"; fi; 
done; 

# Remeber the last one
LAST_MONTHLY=$((i-1))

# make temp folders
if ! [ -d "$HOURLY_PATH/tmp" ]; then mkdir "$HOURLY_PATH/tmp"; fi;
if ! [ -d "$DAILY_PATH/tmp" ]; then mkdir "$DAILY_PATH/tmp"; fi; 
if ! [ -d "$WEEKLY_PATH/tmp" ]; then mkdir "$WEEKLY_PATH/tmp"; fi;
if ! [ -d "$DAILY_PATH/tmp" ]; then mkdir "$DAILY_PATH/tmp"; fi;
if ! [ -d "$MONTHLY_PATH/tmp" ]; then mkdir "$MONTHLY_PATH/tmp"; fi;


# ============================
# rotating snapshots - HOURLY
# ============================

if [ $DO_HOURLY = 1 ]; then 
	
	echo "    doing hourly" 
	
	# ---------- step 1: delete the oldest snapshot (& in the background)
	mv "$HOURLY_PATH/$LAST_HOURLY" "$HOURLY_PATH/tmp" 
	rm -rf "$HOURLY_PATH/tmp" 
	
	# ---------- step 1: drop off the belt (we'll recycle tmp later)
	# mv "$HOURLY_PATH/$LAST_HOURLY" "$HOURLY_PATH/tmp"; 


	
	# ---------- step 2: move along belt 
	#                                         2 -> 3
	#                                         1 -> 2
	#                                         1 no longer exists
	# yes we're twidling with 0 and 1
	
	for (( i=$HOURLY_KEEPS-1; i>1; i-- )) 
	do 
	# echo "$HOURLY_PATH/"$((i-1)) "$HOURLY_PATH/$i"
	   mv "$HOURLY_PATH/"$((i-1)) "$HOURLY_PATH/$i" 
	
	done
	

	# recycle tmp by moving it into the "0" slot on the belt
	# mv "$HOURLY_PATH/tmp" "$HOURLY_PATH/0"
	
	# copy 1 back into 0 (which actually use to be 0 before the belt rotation)
	# gcp -al "$HOURLY_PATH/1/." "$HOURLY_PATH/0"
	
	# ---------- step 3: make a hard-link-only (except for dirs) copy of the latest snapshot "0".
	gcp -al "$HOURLY_PATH/0" "$HOURLY_PATH/1"
	
	sleep 5s
	
	touch "$HOURLY_PATH/0"
	
	touch "$HOURLY_PATH/1"
	
	sleep 5s

	# ---------- step 4: rsync from the system into the latest snapshot "0". Notice that
	# rsync behaves like cp --remove-destination by default, so the destination
	# is unlinked first.  If it were not so, this would copy over the other
	# snapshot(s) too.
	rsync -a --delete --delete-excluded --exclude-from="$EXCLUDES" --link-dest="$HOURLY_PATH/1" "$SRC_PATH" "$HOURLY_PATH/0"
 
	# Update the mtime to reflect now
	# If we do 0 it will revert back to original time stamp, but we do it anyway since i think archives are picking up 0.
	# So by doing 1, we at least get within a good proximity.
	# It would be nice to think about how to get the exact time that 0 was run.
	 
	sleep 5s
	touch "$HOURLY_PATH/0"
	
	touch "$HOURLY_PATH/1"
	
fi; 


if [ $DO_DAILY = 1 ]; then 
	
	echo "    doing daily" 

	# ============================
	# rotating snapshots - DAILY
	# ============================

	# ---------- step 1: delete the oldest snapshot, if it exists:
	# rm -rf $DAILY_PATH/$LAST_DAILY
	mv "$DAILY_PATH/$LAST_DAILY" "$DAILY_PATH/tmp" 
	rm -rf "$DAILY_PATH/tmp" 

	# ---------- step 2: shift the middle snapshots(s) back by one
	for (( i=$DAILY_KEEPS-1; i>0; i-- )) 
	do 
	   mv "$DAILY_PATH/"$((i-1)) "$DAILY_PATH/$i" 
	done 

	# ---------- step 3: make a hard-link copy of the oldest hourly (yesterdays)
	# into today as the first daily
	gcp -al "$HOURLY_PATH/0/." "$DAILY_PATH/0" 

	# Update the mtime to reflect now
	# - I do not think we need to because we're snagging hourly.0 which should have the correct date.
	
	touch "$DAILY_PATH/0"
	
fi; 


if [ $DO_WEEKLY = 1 ]; then 
	
	echo "    doing weekly" 

	# ============================
	# rotating snapshots - WEEKLY
	# ============================

	# ---------- step 1: delete the oldest snapshot, if it exists:
	# rm -rf $WEEKLY_PATH/$LAST_WEEKLY
	mv "$WEEKLY_PATH/$LAST_WEEKLY" "$WEEKLY_PATH/tmp" 
	rm -rf "$WEEKLY_PATH/tmp" 

	# ---------- step 2: shift the middle snapshots(s) back by one
	for (( i=$WEEKLY_KEEPS-1; i>0; i-- )) 
	do 
	   mv "$WEEKLY_PATH/"$((i-1)) "$WEEKLY_PATH/$i" 
	done 

	# ---------- step 3: make a hard-link copy of the latest hourly
	# into today as the first daily
	gcp -al "$HOURLY_PATH/0/." "$WEEKLY_PATH/0" 

	# Update the mtime to reflect now
	# - I don't think we need to because we're snagging hourly.0 which should have the correct date.
	
	touch "$WEEKLY_PATH/0"
	
fi; 

if [ $DO_MONTHLY = 1 ]; then 
	
	echo "    doing monthly" 

	# ============================
	# rotating snapshots - MONTHLY
	# ============================

	# ---------- step 1: delete the oldest snapshot, if it exists:
	# rm -rf $MONTHLY/$LAST_MONTHLY
	mv "$MONTHLY_PATH/$LAST_MONTHLY" "$MONTHLY_PATH/tmp" 
	rm -rf "$MONTHLY_PATH/tmp" 

	# ---------- step 2: shift the middle snapshots(s) back by one
	for (( i=$MONTHLY_KEEPS-1; i>0; i-- )) 
	do 
	   mv "$MONTHLY_PATH/"$((i-1)) "$MONTHLY_PATH/$i" 
	done 

	# ---------- step 3: make a hard-link copy of the latest hourly
	# into today as the first daily
	gcp -al "$HOURLY_PATH/0/." "$MONTHLY_PATH/0" 

	# Update the mtime to reflect now
	# - I don't think we need to because we're snagging hourly.0 which should have the correct date.
	
	touch "$MONTHLY_PATH/0"

fi; 


if [ $DO_ARCHIVE = 1 ]; then 
	
	echo "    doing archive" 

	gcp -al "$HOURLY_PATH/0/." "$ARCHIVE_PATH/$DATE" 
	
	# Update the mtime to reflect now
	# - I don't think we need to because we're snagging hourly.0 which should have the correct date.

	touch "$ARCHIVE_PATH/$DATE"
	
fi; 


	
# Write stamp to store, only if we make it to the end of the script
# FYI - If we shut down part-way through the process, or there's an error

if [ $DO_HOURLY = 1 ]; then 
	echo $STAMP | cat > $STORE_DID_HOURLY
fi; 

if [ $DO_DAILY = 1 ]; then 
	echo $STAMP | cat > $STORE_DID_DAILY
fi; 

if [ $DO_WEEKLY = 1 ]; then 
	echo $STAMP | cat > $STORE_DID_WEEKLY
fi; 

if [ $DO_MONTHLY = 1 ]; then 
	echo $STAMP | cat > $STORE_DID_MONTHLY
fi; 


exit 0; 
