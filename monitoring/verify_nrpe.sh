#!/bin/sh
set -e
cd nagios-nrpe-server-config
echo "Differencing generated nrpe_local.cfg and /etc/nagios/nrpe_local.cfg"
echo "Begin diff..."
diff -bB nrpe_local.cfg /etc/nagios/nrpe_local.cfg
echo "End diff"
cd plugins
echo "Differencing generated plugins and those in /usr/local/lib/nagios/"
echo "Begin diffs..."
for i in * ; do diff -bB $i /usr/local/lib/nagios/$i ; done
echo "End diffs"
echo "If all the differences shown are expected it should be safe to copy"
echo "the generated files into their proper location and then to execute"
echo "	 sudo service nagios-nrpe-server reload"
