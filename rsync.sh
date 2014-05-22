#!/bin/sh

lastUser=`defaults read /Library/Preferences/com.apple.loginwindow lastUserName`

serverAddress='file.jehunw.com'
serverDirectory='Science'

ping -c 1 $serverAddress
if [ $? != 0 ]; then
	echo "Could not connect to the file server. Are you on the office network or VPN?"
	exit 1
fi

mkdir -p /Volumes/$serverDirectory
mountPoint=/Volumes/$serverDirectoy

# Alternate AFP command, calls mount_afp.
#open afp://$serverAddress/$serverFolder
mount_afp -i afp://$serverAddress/$serverDirectory $mountPoint

if [ $? != 0 ]; then
	echo "Could not authenticate/connect to the file server! If you continue to experience problems please contact an administrator."
	exit 2
else
	rsync -av "/Volumes/Science/Papers/Shared Library/" "/Users/$lastUser/Documents/Secure Documents/Literature/Shared Library/"
	if [ $? == 0 ]; then
		echo "Transfer complete!"
	else
		echo "Transfer failed!"
		exit 3
	fi
fi

exit 0 