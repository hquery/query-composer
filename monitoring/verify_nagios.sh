#!/bin/sh
cd nagios-config
echo "Differencing generated commands.cfg and /etc/nagios3/commands.cfg"
echo "Begin diff..."
diff -bB commands.cfg /etc/nagios3/commands.cfg
echo "End diff"
cd conf.d
echo "Differencing generated endpoint specific configuration and those in"
echo "/etc/nagios3/conf.d/pdc-XXX.cfg"
echo "Begin diffs..."
for i in * ; do diff -bB $i /etc/nagios3/conf.d/$i ; done
echo "End diffs"
echo "If all the differences shown are expected it should be safe to copy"
echo "the generated files into their proper location and then to execute"
echo "	/usr/sbin/nagios3 -v /etc/nagios3/nagios.cfg"
echo "If there are no errors or warnings restart Nagios with the new"
echo "configuration by executing"
echo "	 sudo service nagios restart"
