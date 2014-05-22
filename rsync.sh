#!/bin/sh

lastUser=`defaults read /Library/Preferences/com.apple.loginwindow lastUserName`

serverAddress=file.jehunw.com
serverFolder=Science

open afp://$serverAddress/$serverFolder
sleep 10
if [ ! -d /Volumes/$serverFolder ]; then
	echo "Could not connect to the file server!"
	exit 1
else
	rsync -av /Users/$lastUser/Documents/Secure\ Documents/Literature/Shared\ Library/ /Volumes/Science/Papers/Shared\ Library/
	if [ $? == 0 ]; then
		echo "Transfer complete!"
	else
		echo "Transfer failed!"
	fi
fi

exit 0 