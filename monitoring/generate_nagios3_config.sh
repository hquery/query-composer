#!/bin/sh
# 
# Endpoint ids and corresponding checks (Oscar)
ep_ids_oscar="0 1 2 3 4 5 6 7 8 9 11"
ep_checks_oscar="diskspace import load processes swap tomcat users"
# Endpoint ids and corresponding checks (Osler)
ep_ids_osler="50"
ep_checks_osler="diskspace load processes swap users"

print_info() {
  echo
  echo "Hub NRPE server monitoring configuration:"
  echo "----------------------------"
  echo "WARNING: Don't change any NRPE command or plugin that the Nagios host"
  echo "expects to find present on the NRPE server while Nagios is running."
  echo "Otherwise, there is likely to be a flood of alerts."
  echo "NRPE commands are written into ./nagios-nrpe-server-config/nrpe_local.cfg."
  echo "Use this to replace /etc/nagios/nrpe_local.cfg after checking correctness."
  echo "The plugins are written into ./nagios-nrpe-server-config/plugins.  Move the"
  echo "plugins to /usr/local/lib/nagios once they have been checked for correctness."
  echo "The script verify_nrpe.sh will assist in checking the generated files."
  echo "Reload nrpe configuration on the hub using"
  echo "	'sudo service nagios-nrpe-server reload'"
  echo
  echo "Nagios host configuration:"
  echo "-------------------------"
  echo "Nagios commands are written into ./nagios-config/commands.cfg."
  echo "They should be verified carefully and then copied to"
  echo "/etc/nagios3/commands.cfg on the Nagios host."
  echo "Endpoint specific Nagios configuration files are in"
  echo "./nagios-config/conf.d/pdc-XXX.cfg.  They should be"
  echo "verifed carefully and then copied to /etc/nagios3/conf.d/."
  echo "The script verify_nagios.sh will assist in checking the generated files."
  echo "The generated Nagios configuration should then be checked using"
  echo "	'/usr/sbin/nagios3 -v /etc/nagios3/nagios.cfg'"
  echo "If there are no errors or warnings, it should be safe to execute"
  echo "	'sudo service nagios3 restart'"
  echo 
}

# remove and rebuild Nagios configuration and hub NRPE server configuration
/bin/rm -rf nagios-config && /bin/mkdir -p nagios-config/conf.d
/bin/rm -rf nagios-nrpe-server-config && /bin/mkdir -p nagios-nrpe-server-config/plugins

# The function service_description provides a description of
# the service defined in configuration files named
# /etc/nagios3/conf.d/pdc-XXX.cfg on the Nagios host.
# The description is used to provide a informative label
# for the service check on the Nagios services web page.
# Requires one input parameter specifying the service check.
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

generate_endpoint_header() {
  echo "# Custom services specific to this host are added here, but services" 
  echo "# defined in nagios2-common_services.cfg may also apply."
  echo
}

# The function generate_host_definition provides the host definition
# in the configuration files /etc/nagios3/conf.d/pdc-XXX.cfg on the
# Nagios host.
# Requires one input parameter specifying the host id
generate_host_definition() {
  ep_id=$1
  echo
  echo "# commands to check endpoint pdc-$ep_id"
  echo "define host {"
  echo "	use		noping-host"
  echo "	host_name	pdc-$ep_id"
  echo "	check_command	check_alive_pdc$ep_id"
  echo "}"
}

# The function generate_host_service_definition provides the service
# definition in the configuration files /etc/nagios3/conf.d/pdc-XXX.cfg on
# the Nagios host.
# Requires two input parameters specifying the host id and service checked.
generate_host_service_definition() {
  ep_id=$1
  echo "define service {"
  if [ "tomcat" = $2 ]; then
    echo "	use		importhours-service,generic-service"
  else
    echo "	use		generic-service"
  fi
  echo "	host_name	pdc-$ep_id"
  service_description $2
  echo "	check_command	$2_pdc$ep_id"
  echo "}"
}

# The function generate_nagios_command_definition specifies
# the host commands in /etc/nagios3/commands.cfg on the Nagios host.
# Requires two input parameters specifying the host id and the
# service that nagios is checking.  The check_alive service
# is special because it determines whether the query-gateway
# is responding to http requests at the endpoint.  When it
# doesn't respond the host endpoint is considered DOWN.
generate_nagios_command_definition() {
  ep_id=$1
  if [ "alive" = "$2" ]; then
    echo
    echo "# commands to check endpoint pdc-$ep_id"
    echo "define command{"
    echo "	command_name	check_alive_pdc$ep_id"
    echo "	command_line    \$USER1\$/check_nrpe -H 142.104.90.75 -c check_alive_pdc$ep_id"
    echo "}"
  else
    echo "define command{"
    echo "	command_name	$2_pdc$ep_id"
    echo "	command_line    \$USER1\$/check_nrpe -H 142.104.90.75 -c check_$2_pdc$ep_id"
    echo "}"
  fi
}

# The function generate_service_host_plugin generates the
# endpoint service plugin called by the NRPE server on the hub.
# The plugins are kept in /usr/local/lib/nagios on the hub.
# Requires two input parameters, the endpoint id and the
# endpoint service being checked.
generate_service_host_plugin() {
  ep_id=$1
  ep_port=`/usr/bin/expr 10300 + $1`
  /bin/sed "s/ep_port/$ep_port/;s/ep_check/$2/" ./check_service_pdc.template > ./nagios-nrpe-server-config/plugins/check_"$2"_"pdc$ep_id".sh
  chmod +x ./nagios-nrpe-server-config/plugins/check_"$2"_"pdc$ep_id".sh
}

# The function generate_nrpe_command specifies commands that the
# NRPE server can execute on the hub with the add of plugins.
# Requires two input parameters, the endpoint id and the
# endpoint service being checked.
generate_nrpe_command() {
  ep_id=$1
  echo command[check_"$2"_"pdc$ep_id"]=/usr/local/lib/nagios/check_"$2"_"pdc$ep_id".sh
}

# The function generate_alive_command specifies the commands that the NRPE server can
# execute on the hub using check_http to determine whether the query-gateway is running
# at an endpoint.
# Requires one input parameter specifying the endpoint id.
generate_alive_command() {
  ep_id=$1
  ep_port=`/usr/bin/expr 10300 + $1`
  echo "# pdc$ep_id checks"
  echo command[check_alive_"pdc$ep_id"]=/usr/lib/nagios/plugins/check_http -I 127.0.0.1 -p $ep_port
}


cp ./nrpe_local_cfg.prefix ./nagios-nrpe-server-config/nrpe_local.cfg
cp ./commands_cfg.prefix ./nagios-config/commands.cfg

# generate oscar configuration and plugins
for id in $ep_ids_oscar
do
  ep_id=`/usr/bin/expr 1000 + $id | cut -d1 -f2-`
  generate_endpoint_header > ./nagios-config/conf.d/pdc-$ep_id.cfg
  generate_host_definition $ep_id >> ./nagios-config/conf.d/pdc-$ep_id.cfg
  generate_nagios_command_definition $ep_id "alive" >> ./nagios-config/commands.cfg
  generate_alive_command $ep_id >> ./nagios-nrpe-server-config/nrpe_local.cfg
  for check in $ep_checks_oscar
  do
    generate_host_service_definition $ep_id $check >> ./nagios-config/conf.d/pdc-$ep_id.cfg
    generate_nagios_command_definition $ep_id $check >> ./nagios-config/commands.cfg
    generate_service_host_plugin $ep_id $check # writes file directly
    generate_nrpe_command $ep_id $check >> ./nagios-nrpe-server-config/nrpe_local.cfg
  done
done
# generate osler configuration and plugins
for id in $ep_ids_osler
do
  ep_id=`/usr/bin/expr 1000 + $id | cut -d1 -f2-`
  generate_endpoint_header > ./nagios-config/conf.d/pdc-$ep_id.cfg
  generate_host_definition $ep_id >> ./nagios-config/conf.d/pdc-$ep_id.cfg
  generate_nagios_command_definition $ep_id "alive" >> ./nagios-config/commands.cfg
  generate_alive_command $ep_id >> ./nagios-nrpe-server-config/nrpe_local.cfg
  for check in $ep_checks_osler
  do
    generate_host_service_definition $ep_id $check >> ./nagios-config/conf.d/pdc-$ep_id.cfg
    generate_nagios_command_definition $ep_id $check >> ./nagios-config/commands.cfg
    generate_service_host_plugin $ep_id $check # writes file directly
    generate_nrpe_command $ep_id $check >> ./nagios-nrpe-server-config/nrpe_local.cfg
  done
done

print_info
