#!/bin/sh
### Thanks to https://grahamrpugh.com/2017/01/07/application-to-run-shell-commands-with-admin-rights.html
### Script designed to be placed in a "Run Shell Script" action in Automator
### This allows the administrator password to be called, and used in the script where sudo is required
### Beware: the inputted password is used in echo commands
### Usage: Use `sudo` without a path to ensure the `sudo` function is called rather than the actual command

# Dialog Title
dialogTitle="Ardublock and CH34x Installer"

# obtain the password from a dialog box
authPass=$(/usr/bin/osascript <<EOT
tell application "System Events"
    activate
    repeat
        display dialog "Please enter your Apple ID password to start software installation." ¬
            default answer "" ¬
            with title "$dialogTitle" ¬
            with hidden answer ¬
            buttons {"Quit", "Continue"} default button 2
        if button returned of the result is "Quit" then
            return 1
            exit repeat
        else if the button returned of the result is "Continue" then
            set pswd to text returned of the result
            set usr to short user name of (system info)
            try
                do shell script "echo test" user name usr password pswd with administrator privileges
                return pswd
                exit repeat
            end try
        end if
        end repeat
        end tell
EOT
)

# Abort if the Quit button was pressed
if [ "$authPass" == 1 ]; then
    /bin/echo "User aborted. Exiting..."
    exit 0
fi

# function that replaces sudo command
sudo () {
    /bin/echo $authPass | /usr/bin/sudo -S "$@"
}

echo "\n************************************"
echo "\nBarnabas Ardublock and CH34x Driver Beginning...\n"
echo Finding current directory...
cd "$(dirname "$0")"

FILE='ardublock-all-withNewPing.jar'
USERS=$(dscl . list /Users | grep -vE '^_|daemon|nobody|root')
if test -f "./$FILE" ; then
    for u in $USERS; do
        echo "\nCopying $FILE to /Users/$u/Documents/Arduino/tools/ArduBlockTool/tool..."
        sudo mkdir -p /Users/$u/Documents/Arduino/tools/ArduBlockTool/tool
        sudo cp ./$FILE  /Users/$u/Documents/Arduino/tools/ArduBlockTool/tool/
    done
else
    echo "$FILE does not exist"
fi

LIB='NewPing'
USERS=$(dscl . list /Users | grep -vE '^_|daemon|nobody|root')
if test -d "./$LIB" ; then
    for u in $USERS; do
        echo "\nInstalling $LIB Library to /Users/$u/Documents/Arduino/libraries"
        sudo mkdir -p /Users/$u/Documents/Arduino/libraries
        sudo cp -r ./$LIB  /Users/$u/Documents/Arduino/libraries/
    done
else
    echo "$LIB does not exist"
fi

DRIVERZIP='CH34x_Install_V1.5.zip'
DRIVER='CH34x_Install_V1.5.pkg'

if test -f "./$DRIVER"; then
    continue
elif test -f "./$DRIVERZIP"; then
    echo "\nUnzipping Driver"
    unzip $DRIVERZIP
    sudo chmod +x $DRIVER
else
    missing=$(/usr/bin/osascript <<EOT
tell application "System Events"
    activate
        display dialog "CH34x files are missing. Driver not installed." ¬
            with title "$dialogTitle" ¬
            buttons {"Close", "Log"} default button 1
        if button returned of the result is "Close" then
            return 0
        else if the button returned of the result is "Log" then
            return 1
        end if
        end tell
EOT
)
    if [ "$missing" == 1 ]; then
        echo $(date -R) " -Missing files;"  >> ./error.log
    fi
    exit 1
fi

# uninstall any previous drivers
echo "\nUninstalling previous versions of CH34x Driver"

sudo kextunload /Library/Extensions/usbserial.kext
sudo kextunload /System/Library/Extensions/usb.kext
sudo rm -rf /System/Library/Extensions/usb.kext
sudo rm -rf /Library/Extensions/usbserial.kext

# "CH34x Driver exists"
echo "\nInstalling V1.5 CH34x Driver"
echo "\nPlease wait. This may take up to 5 min...\n"
#sudo installer -verboseR -allowUntrusted -pkg $DRIVER -target /
sudo installer -allowUntrusted -pkg $DRIVER -target /

# load driver so that you don't need to restart the computer

echo "\nEnabling CH34x driver to avoid reboot"
sudo kextload /Library/Extensions/usbserial.kext

reStart=$(/usr/bin/osascript <<EOT
tell application "System Events"
    activate
        display dialog "Installation complete! Click 'OK' to close the window." ¬
            with title "$dialogTitle" ¬
            buttons {"OK"} default button 1
        if button returned of the result is "OK" then
            return 0
        # else if the button returned of the result is "Later" then
        #    return 0
        end if
        end tell
EOT
)

# reboot if selected
if [ "$reStart" == 1 ]; then
    sudo reboot
    exit 0
fi

if [ "$reStart" == 0 ]; then
    exit 0
fi
