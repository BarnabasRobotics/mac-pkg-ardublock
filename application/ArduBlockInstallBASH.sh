#!/bin/sh

echo "************************************"
echo "Barnabas Ardublock and CH34x Driver Beginning..."
echo Finding current directory...
cd "$(dirname "$0")"


echo "Installing Arduino"

ARDUINOZIP='arduino-1.8.12-macosx.zip'
ARDUINO='Arduino.app'

if test -f "./$ARDUINO"; then
    mv $ARDUINO /Applications
elif test -f "./$ARDUINOZIP"; then
    #unzip Arduino, if necessary
    echo "\nUnzipping Arduino"
    unzip $ARDUINOZIP
    mv $ARDUINO /Applications
fi

#add Ardublock into tools folder for all users
FILE='ardublock-all-withNewPing.jar'
USERS=$(dscl . list /Users | grep -vE '^_|daemon|nobody|root')
if test -f "./$FILE" ; then
    for u in $USERS; do
        echo "\nCopying $FILE to /Users/$u/Documents/Arduino/tools/ArduBlockTool/tool..."
        
        #remove the previous ardublock folder if it exists
        if [ -d "/Users/$u/Documents/Arduino/tools/ArduBlockTool/tool" ]
        then
            rm -r /Users/$u/Documents/Arduino/tools/ArduBlockTool/tool
        fi
        
        sudo mkdir -p /Users/$u/Documents/Arduino/tools/ArduBlockTool/tool
        sudo cp ./$FILE  /Users/$u/Documents/Arduino/tools/ArduBlockTool/tool/
    done
else
    echo "$FILE does not exist"
fi

#add NewPing library to library folder of all users
LIB='NewPing'
USERS=$(dscl . list /Users | grep -vE '^_|daemon|nobody|root')
if test -d "./$LIB" ; then
    for u in $USERS; do
        echo "Installing $LIB Library to /Users/$u/Documents/Arduino/libraries"
        sudo mkdir -p /Users/$u/Documents/Arduino/libraries
        sudo cp -r ./$LIB  /Users/$u/Documents/Arduino/libraries/
    done
else
    echo "$LIB does not exist"
fi

#unzip driver, if necessary
DRIVERZIP='CH34x_Install_V1.5.zip'
DRIVER='CH34x_Install_V1.5.pkg'

if test -f "./$DRIVER"; then
    echo "Driver exists"
elif test -f "./$DRIVERZIP"; then
    echo "Unzipping Driver"
    unzip $DRIVERZIP
fi

# uninstall any previous drivers
echo "Uninstalling previous versions of CH34x Driver"

sudo kextunload /Library/Extensions/usbserial.kext
sudo kextunload /System/Library/Extensions/usb.kext
sudo rm -rf /System/Library/Extensions/usb.kext
sudo rm -rf /Library/Extensions/usbserial.kext

# "CH34x Driver exists"
echo "Installing V1.5 CH34x Driver"
echo "Please wait. This may take up to 5 min...\n"
sudo installer -verboseR -allowUntrusted -pkg $DRIVER -target /

# load driver so that you don't need to restart the computer
echo "Enabling CH34x driver to avoid reboot"
sudo kextload /Library/Extensions/usbserial.kext

exit 0
