#!/bin/sh
# 
# Endpoint ids (Oscar and Osler specified separately)
ep_ids_oscar="0 1 2 3 4 5 6 7 8 9 11"
ep_checks_oscar="diskspace import load processes swap tomcat users"
ep_ids_osler=""
ep_checks_osler="diskspace load processes swap users"

print_info() {
  echo "Hub monitoring configuration:"
  echo "NRPE commands written into ./nagios-nrpe-server-config/nrpe_local.cfg."
  echo "Use this to replace /etc/nagios/nrpe_local.cfg after carefully checking correctness."
  echo "Called plugins written into ./nagios-nrpe-server-config/plugins."
  echo "Move to /usr/local/lib/nagios once they have been checked for correctness."
  echo "Reload nrpe configuration using 'sudo service nagios-nrpe-server reload'"
}

/bin/rm -rf nagios-config && /bin/mkdir -p nagios-config
/bin/rm -rf nagios-nrpe-server-config && /bin/mkdir -p nagios-nrpe-server-config/plugins

service_description() {
  if [ "diskspace" = $1 ]; then 
    echo "	service_description	Disk Space"
  elif [ "import" = $1 ]; then
    echo "	service_description	Current E2E Import"
  elif [ "load" = $1 ]; then
    echo "	service_description	Current Load"
  elif [ "processes" = $1 ]; then
    echo "	service_description	Total Processes"
  elif [ "swap" = $1 ]; then
    echo "	service_description	Swap Usage"
  elif [ "tomcat" = $1 ]; then
    echo "	service_description	Tomcat Process"
  elif [ "users" = $1 ]; then
    echo "	service_description	Current Users"
  else
    echo $2
  fi
}

generate_host_definition() {
  ep_name=$1
  echo
  echo "# commands to check endpoint pdc-$ep_name"
  echo "define host {"
  echo "	use		noping-host"
  echo "	host_name	pdc$ep_name"
  echo "	check_command	check_alive_pdc$ep_name"
  echo "}"
}

generate_host_service_definition() {
  ep_name=$1
  echo "define service {"
  echo "	use		generic-service"
  echo "	host_name	pdc$ep_name"
  service_description $2
  echo "	check_command	$2_pdc$ep_name"
  echo "}"
}

generate_nagios_command_definition() {
  ep_name=$1
  if [ "alive" = "$2" ]; then
    echo
    echo "# commands to check endpoint pdc-$ep_name"
    echo "define command{"
    echo "	command_name	check_$2_pdc$ep_name"
    echo "	command_line    \$USER1\$/check_nrpe -H 142.104.90.75 -c check_$2_pdc$ep_name"
    echo "}"
  else
    echo "define command{"
    echo "	command_name	$2_pdc$ep_name"
    echo "	command_line    \$USER1\$/check_nrpe -H 142.104.90.75 -c check_$2_pdc$ep_name"
    echo "}"
  fi
}

generate_service_host_plugin() {
  ep_name=$1
  ep_port=`/usr/bin/expr 10300 + $1`
  /bin/sed "s/ep_port/$ep_port/;s/ep_check/$2/" ./check_service_pdc.template > ./nagios-nrpe-server-config/plugins/check_"$2"_"pdc$ep_name".sh
  chmod +x ./nagios-nrpe-server-config/plugins/check_"$2"_"pdc$ep_name".sh
}

generate_nrpe_command() {
  ep_name=$1
  echo command[check_"$2"_"pdc$ep_name"]=/usr/local/lib/nagios/check_"$2"_"pdc$ep_name".sh
}

generate_alive_command() {
  ep_name=$1
  ep_port=`/usr/bin/expr 10300 + $1`
  echo "# pdc$ep_name checks"
  echo command[check_alive_"pdc$ep_name"]=/usr/lib/nagios/plugins/check_http -I 127.0.0.1 -p $ep_port
  echo command[check_tunnel_"pdc$ep_name"]=/usr/lib/nagios/plugins/check_http -H localhost -p $ep_port
}


cp ./nrpe_local_cfg.prefix ./nagios-nrpe-server-config/nrpe_local.cfg
cp ./commands_cfg.prefix ./nagios-config/commands.cfg

# generate oscar configuration and plugins
for id in $ep_ids_oscar
do
  #generate_host_definition $id >> .//nagios-config/commands.cfg
  ep_name=`/usr/bin/expr 1000 + $id | cut -d1 -f2-`
  generate_nagios_command_definition $ep_name "alive" >> ./nagios-config/commands.cfg
  generate_alive_command $ep_name >> ./nagios-nrpe-server-config/nrpe_local.cfg
  for check in $ep_checks_oscar
  do
    generate_nagios_command_definition $ep_name $check >> ./nagios-config/commands.cfg
    generate_service_host_plugin $ep_name $check # writes file directly
    generate_nrpe_command $ep_name $check >> ./nagios-nrpe-server-config/nrpe_local.cfg
  done
done
# generate osler configuration and plugins
for id in $ep_ids_osler
do
  #generate_host_definition $id >> .//nagios-config/commands.cfg
  ep_name=`/usr/bin/expr 1000 + $id | cut -d1 -f2-`
  generate_nagios_command_definition $ep_name "alive" >> ./nagios-config/commands.cfg
  generate_alive_command $ep_name >> ./nagios-nrpe-server-config/nrpe_local.cfg
  for check in $ep_checks_osler
  do
    generate_nagios_command_definition $ep_name $check >> ./nagios-config/commands.cfg
    generate_service_host_plugin $ep_name $check # writes file directly
    generate_nrpe_command $ep_name $check >> ./nagios-nrpe-server-config/nrpe_local.cfg
  done
done

print_info
