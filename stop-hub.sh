#!/bin/bash
source $HOME/.bash_profile
source $HOME/.bashrc
export HUB=$HOME/git/scoophealth/hquery/query-composer
export HB_PIDFILE=$HUB/tmp/pids/server.pid
export DL_PIDFILE=$HUB/tmp/pids/delayed_job.pid
cd $HUB
if [ -f $DL_PIDFILE ];
then
  bundle exec $HUB/script/delayed_job stop
  # pid file should be gone but recheck
  if [ -f $DL_PIDFILE ];
  then
    rm $DL_PIDFILE
  fi
fi
#
# If gateway is running, stop it.
if [ -f $HB_PIDFILE ];
then
  kill `cat $HB_PIDFILE`
  if [ -f $HB_PIDFILE ];
  then
    kill -9 `cat $HB_PIDFILE`
  fi
  rm $HB_PIDFILE
fi
