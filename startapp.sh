#!/bin/bash

. /files/HandBrake.conf

function ts {
  echo [`date '+%b %d %X'`]
}

#-----------------------------------------------------------------------------------------------------------------------

if [ "$USE_UI" == "yes" ]
then
  echo "$(ts) Running HandBrake GUI"
  /usr/bin/ghb
else
  echo "$(ts) Not running HandBrake GUI"
  # Give services some time to start before we kill them
  sleep 5
  sv stop guacd tomcat7 xrdp xrdp-sesman openbox
  rm -rf /etc/service/handbrake-ui
fi
