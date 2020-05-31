#!/bin/sh

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
