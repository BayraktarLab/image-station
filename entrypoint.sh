#!/usr/bin/env bash

# create $HOME/.vnc folder to keep necesary files there
mkdir -p $HOME/.vnc

# if no password is provided a random one is generated
if [[ -z "${NOVNC_PASSWORD}" ]]; then
  NOVNC_PASSWORD="$(whoami)$(date '+%M%S')"
fi
# generate vnc password using NOVNC_PASSWORD 
echo -n "${NOVNC_PASSWORD}" | vncpasswd -f > $HOME/.vnc/passwd
chmod 600 $HOME/.vnc/passwd

# generate self signed cert for websockify
#openssl req -x509 -nodes -newkey rsa:2048 -keyout $HOME/.vnc/cert.key -out $HOME/.vnc/cert.pem -subj "/C=GB/ST=London/L=London/O=Wellcome Trust Sanger Institute/OU=Cellular Genetics/CN=*"

# use .Xauthority from $HOME/.vnc folder
export XATHORITY=$HOME/.vnc/.Xauthority

# use given port or default 5901
NOVNC_PORT="${NOVNC_PORT:-5901}"

# show access information
echo -e "#--------------------------------------------------------------------------------"
echo -e "#-- 🌐 Browse address:\thttp://$(hostname).internal.sanger.ac.uk:${NOVNC_PORT}"
echo -e "#-- 🔐 noVNC password:\t${NOVNC_PASSWORD}" 
echo -e "#--------------------------------------------------------------------------------"

# launch websockifly start vncserver and exec virtualgl sessionxfc4 
/opt/websockify/run "${NOVNC_PORT}" --web=/opt/noVNC --wrap-mode=ignore -- vncserver :1 -rfbauth $HOME/.vnc/passwd -securitytypes vnc -xstartup /opt/xstartup
