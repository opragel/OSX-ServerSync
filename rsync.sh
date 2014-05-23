#!/bin/sh
clear
echo 'OSX ServerSync V2'

lastUser=`defaults read /Library/Preferences/com.apple.loginwindow lastUserName`
serverAddress='example'

ping -c 1 $serverAddress > /dev/null 2>&1
if [ $? != 0 ]; then
	echo "Server not found! Are you on the office network or VPN?"
	exit 1
fi

serverDisk='example'
serverDirectory='example' # Path below intended to be absolute - see rsync line
mountPoint="/Volumes/$serverDisk"
localDestination='example'

if [ ! -d $mountPoint ]; then	
	open afp://$serverAddress/$serverDisk # Alternates: mount -t afp, mount_afp
	sleep 8
fi

if [ ! -d $mountPoint ]; then
	echo "Server failed to connect! Contact an admin if issue persists."
	exit 2
fi

if find $mountPoint$serverDirectory -maxdepth 0 -empty | read v; then
	isEmpty=1
fi

if [ "$isEmpty" == 1 ]; then
	echo 'Remote folder is empty! If it is really not, contact an admin.'
	exit 3
else
	echo "Connected to server! Syncing"\
	"$serverAddress/$serverDisk$serverDirectory to $localDestination..."
	rsync -av "$mountPoint$serverDirectory" "$localDestination"
	if [ $? == 0 ]; then
		echo "Transfer complete!"
	else
		echo "Transfer failed!"
		exit 4
	fi
fi

exit 0 