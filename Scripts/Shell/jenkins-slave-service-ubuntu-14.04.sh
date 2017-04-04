#!/bin/bash
#
# /etc/init.d/jenkins-slave
#
# Update permission and owner =>
# sudo chmod 755 /etc/init.d/jenkins-slave
# sudo chown root:root /etc/init.d/jenkins-slave
#
# To add the script to autostart call =>
# sudo update-rc.d jenkins-slave defaults
#
# To remove the script from autostart call =>
# sudo update-rc.d -f jenkins-slave remove
#
### BEGIN INIT INFO
# Provides:          jenkins-slave
# Required-Start:    $local_fs $remote_fs $network $syslog $named
# Required-Stop:     $local_fs $remote_fs $network $syslog $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts jenkins-slave
# Description:       Starts jenkins-slave
### END INIT INFO

Name="Jenkins Slave"
InstanceName="application-name"
JenkinsCertification="<certification hash>"
JenkinsUrl="http://jenkins.test"
Log="/var/log/jenkins"
Pidfile="/var/run/jenkins-slave.pid"
JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

case "$1" in
   start)
      touch $Log
      chown root $Log
      echo "Starting $Name">>$Log
      "$JAVA_HOME/bin/java" -jar /opt/jenkins/config/slave.jar -jnlpUrl $JenkinsUrl/computer/$InstanceName/slave-agent.jnlp -secret $JenkinsCertification 2>>$Log >>$Log &
      Pid=$!
      if [ -z $Pid ]; then
         printf "%s\n" "Fail"
      else
         echo $Pid > $Pidfile
         printf "%s\n" "Ok"
      fi
      ;;

   stop)
      printf "%-50s" "Stopping $Name"
      Pid=`cat $Pidfile`
      if [ -f $Pidfile ]; then
         kill -TERM $Pid
         printf "%s\n" "Ok"
         rm -f $Pidfile
      else
         printf "%s\n" "pidfile not found"
      fi
      ;;

   restart)
      $0 stop
      $0 start
      ;;

   status)
      printf "%-50s" "Checking $Name..."
      if [ -f $Pidfile ]; then
         Pid=`cat $Pidfile`
         if [ -z "`ps axf | grep ${Pid} | grep -v grep`" ]; then
            printf "%s\n" "Process dead but pidfile exists"
            echo "Pidfile: $Pidfile"
         else
            echo "Running"
            echo "Pid: $Pid"
            echo "Pidfile: $Pidfile"
         fi
      else
         printf "%s\n" "Service not running"
      fi
      ;;

   *)
      echo "Usage: $0 {start|stop|restart}"
      ;;
esac
