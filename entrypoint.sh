#!/usr/bin/env bash

# create $HOME/.vnc folder to keep necesary files there
mkdir -p $HOME/.vnc

VNC_PASSWD="$HOME/.vnc/passwd"
# if no password is provided a random one is generated
if [[ -z "${NOVNC_PASSWORD}" ]]; then
  NOVNC_PASSWORD="$(whoami)$(date '+%M%S')"
fi
# generate vnc password using NOVNC_PASSWORD 
echo -n "${NOVNC_PASSWORD}" | vncpasswd -f > ${VNC_PASSWD}
chmod 600 ${VNC_PASSWD}

# generate self signed cert for websockify
#openssl req -x509 -nodes -newkey rsa:2048 -keyout $HOME/.vnc/cert.key -out $HOME/.vnc/cert.pem -subj "/C=GB/ST=London/L=London/O=Wellcome Trust Sanger Institute/OU=Cellular Genetics/CN=*"

# use .Xauthority from $HOME/.vnc folder
export XATHORITY=$HOME/.vnc/.Xauthority

export XDG_RUNTIME_DIR=$HOME/.xdg
mkdir -p $XDG_RUNTIME_DIR

# use random port if not provided
if [[ -z "${NOVNC_PORT}" ]]; then
  NOVNC_PORT=`python3 -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()'`
fi

#export DISPLAY=":$RANDOM"
export DISPLAY=:1

# show access information
echo -e "#--------------------------------------------------------------------------------"
echo -e "#-- 🌐 Browse address:\thttp://$(hostname).internal.sanger.ac.uk:${NOVNC_PORT}"
echo -e "#-- 🔐 noVNC password:\t${NOVNC_PASSWORD}" 
echo -e "#--------------------------------------------------------------------------------"
echo -e "#-- 📓 For custom values use these options before launch:"
echo -e "#--  ├─ Port: 'export NOVNC_PORT=<PORT_NUMBER>'"
echo -e "#--  └─ Password: 'export NOVNC_PASSWORD=<PASSWORD>'"
echo -e "#--------------------------------------------------------------------------------"

# create unix domain socket on which vncserver listens for connections from websockify
#VNC_SOCKET="$HOME/.vnc/.socket"

# launch websockifly start vncserver and exec virtualgl sessionxfc4 
# TODO try unix sockets: --unix-target=${VNC_SOCKET} / -rfbunixpath ${VNC_SOCKET} 
/opt/websockify/run ${NOVNC_PORT} \
  --web=/opt/noVNC \
  --wrap-mode=ignore \
  -- \
    vncserver \
      -name "[$(whoami)] Image Station" \
      -verbose \
      -rfbport ${NOVNC_PORT} \
      -rfbauth ${VNC_PASSWD} \
      -securitytypes vnc -xstartup \
      /opt/xstartup $DISPLAY

