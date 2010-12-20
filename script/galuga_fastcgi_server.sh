#!/bin/bash
#
# galuga_fastcgi_server.sh : galuga fastcgi daemon start/stop script
#
# version : 0.05
#
# chkconfig: 2345 84 16
# description: galuga fastcgi daemon start/stop script
# processname: fcgi
# pidfile: /var/run/galuga.pid
#
# 2010-12-19 by Yanick Champoux,,,

# Load in the best success and failure functions we can find
if [ -f /etc/rc.d/init.d/functions ]; then
    . /etc/rc.d/init.d/functions
else
    # Else locally define the functions
    success() {
        echo -e "\n\t\t\t[ OK ]";
        return 0;
    }

    failure() {
        local error_code=$?
        echo -e "\n\t\t\t[ Failure ]";
        return $error_code
    }
fi

RETVAL=0
prog="galuga"
SU=su
EXECUSER=galuga
EXECDIR=/home/galuga/galuga
PID=/home/galuga/pid/galuga.pid
LOGFILE=/home/galuga/logs/daemon.log
PROCS=3
SOCKET=localhost:8686


# your application environment variables
export GALUGA_CONFIG="/home/galuga/conf"
export PERLBREW_ROOT=/usr/local/perl
source /usr/local/perl/etc/bashrc

if [ -f "/etc/sysconfig/"$prog ]; then
  . "/etc/sysconfig/"$prog
fi

start() {
  if [ -f $PID ]; then
    echo "already running..."
      return 1
    fi
    # Start daemons.
    echo -n $"Starting Galuga: "
    touch ${LOGFILE}
    echo -n "["`date +"%Y-%m-%d %H:%M:%S"`"] " >> ${LOGFILE}
    if [ "$USER"x != "$EXECUSER"x ]; then
      $SU $EXECUSER -c "(export PATH=$PATH;cd ${EXECDIR};script/galuga_fastcgi.pl -n ${PROCS} -l ${SOCKET} -p ${PID} -d >> ${LOGFILE} 2>&1)"
    else
      cd ${EXECDIR}
      script/galuga_fastcgi.pl -n ${PROCS} -l ${SOCKET} -p ${PID} -d >> ${LOGFILE} 2>&1
    fi
    RETVAL=$?
    [ $RETVAL -eq 0 ] && success || failure $"$prog start"
    echo
    return $RETVAL
}

stop() {
  # Stop daemons.
  echo -n $"Shutting down Galuga: "
  echo -n "["`date +"%Y-%m-%d %H:%M:%S"`"] " >> ${LOGFILE}
  /bin/kill `cat $PID 2>/dev/null ` >/dev/null 2>&1 && (success; echo "Stoped" >> ${LOGFILE} ) || (failure $"$prog stop";echo "Stop failed" >> ${LOGFILE} )
  /bin/rm $PID >/dev/null 2>&1
  RETVAL=$?
  echo
  return $RETVAL
}

status() {
  # show status
  if [ -f $PID ]; then
    echo "${prog} (pid `/bin/cat $PID`) is running..."
  else
    echo "${prog} is stopped"
  fi
  return $?
}

restart() {
  stop
  start
}

# See how we were called.
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  status)
    status
    ;;
  *)
    echo $"Usage: $0 {start|stop|restart|status}"
    exit 1
esac
exit $?
