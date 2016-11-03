#!/bin/bash
echo "Starting Firebird DB Server";
/usr/sbin/fbguard &;
echo "Starting Glassfish Application Server";
/glassfish4/bin/asadmin start-domain;
echo "Starting SSH Server";
/usr/sbin/sshd -D &;