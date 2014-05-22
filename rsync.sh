#!/bin/sh

lastUser=`defaults read /Library/Preferences/com.apple.loginwindow lastUserName`

serverAddress='file.jehunw.com'
serverDisk='Science'
# Path below intended to be absolute - see rsync line
serverDirectory='/Papers/Shared Library/'

ping -c 1 $serverAddress
if [ $? != 0 ]; then
	echo "Could not connect to the file server. Are you on the office network or VPN?"
	exit 1
fi

mkdir -p /Volumes/$serverDisk
mountPoint=/Volumes/$serverDisk
localDirectory="/Users/$lastUser/Documents/Secure Documents/Literature/Shared Library/"

# Alternate AFP command, calls mount_afp.
#open afp://$serverAddress/$serverFolder
mount_afp -i afp://$serverAddress/$serverDisk $mountPoint

if [ $? != 0 ]; then
	echo "Could not authenticate/connect to the file server! If you continue to experience problems please contact an administrator."
	
	exit 2
else
	rsync -av "$mountPoint$serverDirectory" "$localDirecory"
	if [ $? == 0 ]; then
		echo "Transfer complete!"
	else
		echo "Transfer failed!"
		exit 3
	fi
fi

exit 0 