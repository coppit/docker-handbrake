#!/bin/bash

set -e

if [ -f "/config/HandBrake.conf" ]; then
    echo "Using existing configuration. May require editing."
else
    cp /files/HandBrake.conf.default /config/HandBrake.conf
    echo "Creating /config/HandBrake.conf and exiting. Please edit the configuration and restart the container."
    exit 1
fi

#-----------------------------------------------------------------------------------------------------------------------

chmod +x /files/runas.sh
chmod +x /files/monitor.py
mkdir -p /config

#-----------------------------------------------------------------------------------------------------------------------

# Get the configured $USER_ID, $GROUP_ID, and $UMASK
. /config/HandBrake.conf

/files/runas.sh $USER_ID $GROUP_ID $UMASK echo "Ensuring user and group exists"

HOME_DIR=$(getent passwd $USER_ID | cut -d: -f6)
mkdir -p $HOME_DIR/.config
rm -f $HOME_DIR/.config/ghb
ln -s /config/handbrake $HOME_DIR/.config/ghb

#-----------------------------------------------------------------------------------------------------------------------

chown -R $USER_ID:$GROUP_ID /config

#-----------------------------------------------------------------------------------------------------------------------

tr -d '\r' < /config/HandBrake.conf >> /files/HandBrake.conf

echo "COMMAND='/bin/bash /files/convert.sh'" >> /files/HandBrake.conf
echo "WATCH_DIR=/watch" >> /files/HandBrake.conf
