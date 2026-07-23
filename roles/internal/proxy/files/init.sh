#! /bin/sh
### BEGIN INIT INFO
# Provides:          tinyproxy
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Tinyproxy HTTP proxy
# Description:       Start, stop or reload tinyproxy.
### END INIT INFO
#
# Tinyproxy init.d script
# Ed Boraas 1999
#

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
CONFIG=/etc/tinyproxy.conf
DAEMON=/usr/local/bin/tinyproxy
DESC=tinyproxy
FLAGS=
NAME=tinyproxy

if [ -r /etc/default/tinyproxy ]; then
    . /etc/default/tinyproxy
fi

test -f $DAEMON || exit 0

set -e

# assert pidfile directory and permissions
if [ "$1" != "stop" ]; then
    if [ -f "$CONFIG" ]; then
        USER=$(grep    -i '^User[[:space:]]'    "$CONFIG" | awk '{print $2}')
        GROUP=$(grep   -i '^Group[[:space:]]'   "$CONFIG" | awk '{print $2}')
        PIDFILE=$(grep -i '^PidFile[[:space:]]' "$CONFIG" | awk '{print $2}' |\
          sed -e 's/"//g')
        PIDDIR=`dirname "$PIDFILE"`
        if [ -n "$PIDDIR" -a "$PIDDIR" != "/var/run" ]; then
	    if [ ! -d "$PIDDIR" ]; then
                mkdir "$PIDDIR"
            fi
            if [ "$USER" ]; then
                chown "$USER" "$PIDDIR"
            fi
            if [ "$GROUP" ]; then
                chgrp "$GROUP" "$PIDDIR"
            fi
        fi
    fi
fi

case "$1" in
  start)
	echo -n "Starting $DESC: "
	start-stop-daemon --start --quiet -o --exec $DAEMON -- $FLAGS
	echo "$NAME."
	;;
  stop)
	echo -n "Stopping $DESC: "
	start-stop-daemon --stop --quiet -o --exec $DAEMON
	echo "$NAME."
	;;
  reload|force-reload)
	 echo "Reloading $DESC configuration files."
	 start-stop-daemon --stop --signal 1 --quiet -o --exec $DAEMON
	;;
  restart)
	echo -n "Restarting $DESC: "
	start-stop-daemon --stop --quiet -o --exec $DAEMON
	sleep 1
	start-stop-daemon --start --quiet -o --exec $DAEMON -- $FLAGS
	echo "$NAME."
	;;
  *)
	N=/etc/init.d/$NAME
	echo "Usage: $N {start|stop|restart|reload|force-reload}" >&2
	exit 1
	;;
esac

exit 0
