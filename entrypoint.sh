#!/usr/bin/env bash

mkdir -p $HOME/.vnc

if [[ -z "${NOVNC_PASSWORD}" ]]; then
  NOVNC_PASSWORD="$(whoami)$(date '+%M%S')"
  echo "#--------------------------------------------------"
  echo "#-- Your noVNC password is: ${NOVNC_PASSWORD}"
  echo "#--------------------------------------------------"
fi

echo -n "${NOVNC_PASSWORD}" | vncpasswd -f > $HOME/.vnc/passwd
chmod 600 $HOME/.vnc/passwd

export XATHORITY=$HOME/.vnc/.Xauthority

/opt/websockify/run "${NOVNC_PORT:-5901}" --cert=/self.pem --web=/opt/noVNC --wrap-mode=ignore -- vncserver :1 -rfbauth $HOME/.vnc/passwd -securitytypes vnc -xstartup /opt/xstartup
