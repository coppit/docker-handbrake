#!/bin/bash

. /files/HandBrake.conf

function ts {
  echo [`date '+%b %d %X'`]
}

#-----------------------------------------------------------------------------------------------------------------------

export DISPLAY=:1

if [ "$USE_UI" == "yes" ] || [ "$USE_UI" == "true" ]
then
  echo "$(ts) Running HandBrake GUI"
  /usr/bin/ghb
else
  echo "$(ts) Not running HandBrake GUI"
  # Give services some time to start before we kill them
  sleep 5
  sv stop guacd tomcat7 xrdp xrdp-sesman openbox

  while true
  do
    sleep 300
  done
fi
