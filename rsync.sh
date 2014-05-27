#!/bin/sh
clear
echo 'OSX ServerSync V4'

displayNotification() {
  if [[ -z "$1" || -z "$2" ]]; then
    osascript -e 'display notification "Missing message or title. No notification passed."'
    sleep 1
    echo -e "Missing message or title. No notification passed."
    return 1
  else
    osascript -e "display notification \"$1\" with title \"$2\""
    sleep 1
    echo "$1"
  fi
  return 0
}

lastUser=`defaults read /Library/Preferences/com.apple.loginwindow lastUserName`
serverAddress='file.jehunw.com'

connectionErrorTitle="Connection Failure!"
emptyErrorTitle="Nothing to sync!"

pingError="The server $serverAddress is not responding.\nAre you connected to the office network?"
authError="Authentication to $serverAddress failed.\nContact an administrator if the issue persists."
emptyError="Remote folder is empty! If incorrect and the issue persists, please contact an administrator.'"

serverDisk='Science'
serverDirectory='/test/' # Path below intended to be absolute - see rsync line
mountPoint="/Volumes/$serverDisk"
localDestination="/Users/$lastUser/Documents/test/"

ping -c 1 $serverAddress > /dev/null 2>&1
if [ $? != 0 ]; then
  displayNotification "$pingError" "$connectionErrorTitle"
	exit 1
fi

if [ ! -d $mountPoint ]; then	
	open afp://$serverAddress/$serverDisk # Alternates: mount -t afp, mount_afp
	sleep 8
fi

if [ ! -d $mountPoint ]; then
	displayNotification "$authError" "$connectionErrorTitle"
	exit 2
fi

if find $mountPoint$serverDirectory -maxdepth 0 -empty | read v; then
	isEmpty=1
fi

if [ "$isEmpty" == 1 ]; then
  displayNotification "$emptyError" "$emptyErrorTitle"
	exit 3
else
  confirmSync=`osascript << EOT
  tell app "System Events"
     Activate
     display dialog "Synchronize and overwrite\n$serverAddress/$serverDisk$serverDirectory to\n$localDestination?" buttons {"OK", "Cancel"} default button 1 with title "Confirm folder synchronization?" with icon caution
  end tell`
  if [ $? == 0 ]; then
    displayNotification "Synchronizing $serverDisk$serverDirectory to $localDestination" "Transferring.."
    rsync -av "$mountPoint$serverDirectory" "$localDestination"
    if [ $? == 0 ]; then
    	displayNotification "$serverAddress/$serverDisk$serverDirectory successfully transferred to $localDestination" "Transfer Complete!"
    else
    	displayNotification "$serverDisk$serverDirectory failed to transfer." "Transfer Failed!"
    	exit 4
    fi
  else
    displayNotification "Transfer cancelled by user." "Transfer cancelled."
    exit 5
  fi
fi

exit 0 