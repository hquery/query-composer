#!/bin/bash
source $HOME/.bash_profile
source $HOME/.bashrc
export HUB=$HOME/git/scoophealth/hquery/query-composer
export HB_PIDFILE=$HUB/tmp/pids/server.pid
export DL_PIDFILE=$HUB/tmp/pids/delayed_job.pid

#
# Make sure mongod is running
if ! pgrep mongod > /dev/null
then
  sudo service mongod start
fi
#
#
echo "Starting Query Composer on port 3002"
cd $HUB
if [ -f $DL_PIDFILE ];
then
  bundle exec $HUB/script/delayed_job stop
  if [ -f $DL_FILEFILE ];
  then
    rm $DL_PIDFILE
  fi
fi
#
bundle exec $HUB/script/delayed_job start
#
# Start composer
# If composer is already running (or has a stale server.pid), try to stop it.
if [ -f $HB_PIDFILE ];
then
  kill `cat $HB_PIDFILE`
  if [ -f $HB_PIDFILE ];
  then
    kill -9 `cat $HB_PIDFILE`
    rm $HB_PIDFILE
  fi
fi
bundle exec rails server -p 3002 -d
#/bin/ps -ef | grep "rails server -p 3002" | grep -v grep | awk '{print $2}' > tmp/pids/server.pid
