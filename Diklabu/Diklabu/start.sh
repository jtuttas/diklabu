#!/bin/bash
echo "Starting Firebird DB Server"
/usr/sbin/fbguard &
echo "Starting Payara Application Server"
/opt/payara6/bin/asadmin start-domain
echo "Kopiere template.txt..."
cp /etc/diklabu/template.txt /opt/payara6/glassfish/domains/domain1/docroot/ 
echo "Deploying diklabu Application"
/opt/payara6/bin/asadmin --user admin --passwordfile=/tmp/payarapwd deploy /home/diklabu/diklabu/Diklabu/dist/Diklabu.war 
echo "Starting SSH Server"
/usr/sbin/sshd -D &