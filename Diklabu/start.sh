#!/bin/bash
echo "Starting Firebird DB Server"
/usr/sbin/fbguard &
echo "Building Database structure"
isql-fb -i /home/diklabu/diklabu/Diklabu/Sql_buils.sql        
echo "Starting Glassfish Application Server"
/glassfish4/bin/asadmin start-domain
echo "Starting SSH Server"
/usr/sbin/sshd -D &