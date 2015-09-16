#!/bin/sh
# 
print_info() {
  echo "Plugins written into ./tmp.  Move to /usr/local/lib/nagios once they"
  echo "have been checked for correctness."
  echo "NRPE commands written into ./nrpe_local.cfg.  Use this to replace"
  echo "/etc/nagios/nrpe_local.cfg after carefully checking correctness."
  echo "Reload nrpe plugins using 'sudo service nagios-nrpe-server reload'"
}

generate_service_host_plugin() {
  if [ ! -d ./tmp ]; then
    /bin/mkdir tmp
  fi
  ep_name=`/usr/bin/expr 1000 + $1 | cut -d1 -f2-`
  ep_port=`/usr/bin/expr 10300 + $1`
  /bin/sed "s/ep_port/$ep_port/;s/ep_check/$2/" ./check_service_pdc.template > ./tmp/check_"$2"_"pdc$ep_name".sh
  chmod +x ./tmp/check_"$2"_"pdc$ep_name".sh
}

generate_nrpe_command() {
  ep_name=`/usr/bin/expr 1000 + $1 | cut -d1 -f2-`
  echo command[check_"$2"_"pdc$ep_name"]=/usr/local/lib/nagios/check_"$2"_"pdc$ep_name".sh
}

generate_alive_command() {
  ep_name=`/usr/bin/expr 1000 + $1 | cut -d1 -f2-`
  ep_port=`/usr/bin/expr 10300 + $1`
  echo "# pdc$ep_name checks"
  echo command[check_alive_"pdc$ep_name"]=/usr/lib/nagios/plugins/check_http -I 127.0.0.1 -p $ep_port
  echo command[check_tunnel_"pdc$ep_name"]=/usr/lib/nagios/plugins/check_http -H localhost -p $ep_port
}

ep_ids_oscar="0 1 2 3 4 5 6 7 8 9 11"
ep_checks_oscar="diskspace import load processes swap tomcat users"
ep_ids_osler="50"
ep_checks_osler="diskspace load processes swap users"

cp ./nrpe_local_cfg.template ./nrpe_local.cfg

# generate oscar configuration and plugins
for id in $ep_ids_oscar
do
  generate_alive_command $id >> ./nrpe_local.cfg
  for check in $ep_checks_oscar
  do
    generate_service_host_plugin $id $check
    generate_nrpe_command $id $check >> ./nrpe_local.cfg
  done
done
# generate osler configuration and plugins
for id in $ep_ids_osler
do
  generate_alive_command $id >> ./nrpe_local.cfg
  for check in $ep_checks_osler
  do
    generate_service_host_plugin $id $check
    generate_nrpe_command $id $check >> ./nrpe_local.cfg
  done
done

print_info
