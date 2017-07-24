#!/bin/bash
echo "Starting Firebird DB Server"
/usr/sbin/fbguard &
echo "Starting Glassfish Application Server"
/glassfish4/bin/asadmin start-domain
echo "Deploying diklabu Application"
/glassfish4/bin/asadmin --user admin --passwordfile=/tmp/glassfishpwd deploy /home/diklabu/diklabu/Diklabu/dist/Diklabu.war 
echo "Starting SSH Server"
/usr/sbin/sshd -D &