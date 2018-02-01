# Backup

v 1.0

Backup is a simple macOS shell script for backing up files from one drive to another. 

- Backed up files are clear and accessible through the file system, and don't require any kind of special software to access them.
- Backup is based off of [Mike Rubel's original abstract](http://www.mikerubel.org/computers/rsync_snapshots/). But it's been simplified and developed specifically for macOS.
- Leverages [__rsync__](https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/rsync.1.html) with "hard links" to minimize data usage on the backup drive, however finalized "deep" storage archives in the "monthly" folder are decoupled to physical files. All other backup locations maintain "hard links".

# Installation & Setup

Make the "backup.sh" file executable:

	chmod +x backup.sh

Edit "backup.sh" and adjust the "locations" section to point to source and destination folders:

	# Locations
	# ----------------------------
	# NO TRAILING SLASH
	SRC_PATH="/Volumes/Drives"
	BACKUP_PATH="/Volumes/BU12/backups"
	EXCLUDES="/scripts/rsync/excludes.txt"


SRC_PATH
: The source folder you want to backup

BACKUP_PATH
: The destination where the backups will reside. Note that this script automatically generates files and folders in this destination, so it should be an empty folder.

EXCLUDES
: The path to a text file that lists (glob) files to skip. Place each entry on a newline. Example:


		.Spotlight-*/
		.Trashes
		.DS_Store
		.fseventsd
		.com.apple.timemachine.donotpresent
		*/.Trash
		.DocumentRevisions-V100
		.TemporaryItems
		*.app/*

### Errors
Errors are logged to a file named "errors.log" in the same folder as "backup.sh".
	
# Usage

Run from the command line with the following:

	cd /scripts/rsync
	./backup.sh

By default (without flag/argument) will do whatever needs to be done.

> Backup figures out what needs to be done based on previous backup session by reading the timestamp in "_LAST_X" to see when X was last run, and deciding what to do accordingly.

### Flags

	./backup.sh 	(no flag = recommended)
	./backup.sh -h 	(help) Shows this usage info
	./backup.sh -a 	(generate archive)
	./backup.sh -d 	(run daily)
	./backup.sh -w 	(run weekly)
	./backup.sh -m 	(run monthly)
	


# Requirements

#### GCP

Requires gcp, which is a replacement for traditional "cp" (copy file), which can be installed using:

1. Install [__Brew__](https://brew.sh/) first (if its not installed already)

		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

2. Install coreutils

		brew install coreutils
	
> FYI: Mac's "cp" (copy file) doesn't provide a mechanism to "hard link" files. By installing coreutils, Mac OS X utilities are replaced with GNU core utilities.




# Launch Deamons

Use a launch deamon to have the backup.sh run at specified times.

The clarity between LaunchAgents and LaunchDeamons can get stale when not used day-today, this should help:

### Who does what

~/Library/LaunchAgents
: Per-user agents provided by the user.

/Library/LaunchAgents
: Per-user agents provided by the administrator.

/Library/LaunchDaemons
: System-wide daemons provided by the administrator.

/System/Library/LaunchAgents
: Per-user agents provided by OS X.

/System/Library/LaunchDaemons
: System-wide daemons provided by OS X.

### Commands

List deamons

	launchctl list

Stop job - !!! use list above to find actual name of job (may be different from your plist file)

	launchctl stop com.gieson.launcha.backup


Remove deamon (use actual file location)

	launchctl unload /Library/LaunchDaemons/com.gieson.launcha.backups.plist

Load a job:

> NOTE: Jobs will automatically be loaded at boot if they reside in the LaunchAgents" folder.

	launchctl load /Library/LaunchDaemons/com.gieson.launcha.backups.plist

Start a job (use the job Label (not file name))

	launchctl start com.gieson.launcha.backups


### Setup A Launch Deamon

Put plist into:

	/Library/LaunchDaemons

... and set proper owner / permissions:

	sudo launchctl unload /Library/LaunchDaemons/com.gieson.launcha.backups.plist
	sudo cp /scripts/rsync/com.gieson.launcha.backups.plist /Library/LaunchDaemons/com.gieson.launcha.backups.plist
	sudo chmod 644 /Library/LaunchDaemons/com.gieson.launcha.backups.plist
	sudo chown root:wheel /Library/LaunchDaemons/com.gieson.launcha.backups.plist
	sudo launchctl load /Library/LaunchDaemons/com.gieson.launcha.backups.plist

