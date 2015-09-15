The local configuration is stored in /etc/nagios/nagios_local.cnf to make
it easier to find non-default behaviour.

Changes made to nagios_local.cnf do not take effect until nagios-nrpe-server is restarted or the following command is issued:

$ sudo service nagios-nrpe-server reload

The PDC specific command definitions execute plugins stored in /usr/local/lib/nagios.
