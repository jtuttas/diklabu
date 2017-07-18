FROM ubuntu:16.04
MAINTAINER Joerg Tuttas <tuttas@mmbbs.de>
ENV DEBIAN_FRONTEND noninteractive

#Install firebird
RUN \
  apt-get update && \
  apt-get install -y firebird2.5-super && \
  sed -ri 's/RemoteBindAddress = localhost/RemoteBindAddress = /g' /etc/firebird/2.5/firebird.conf && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# forward logs to docker log collector
#RUN ln -sf /dev/stdout /var/log/firebird/firebird2.5.log

#install Utils
RUN apt-get -qq update && \
       apt-get -qq -y install nano && \
       apt-get -qq -y install git && \
       apt-get -qq -y install mc  
   #     apt-get -qq -y install net-tools 

VOLUME /var/lib/firebird/2.5/data
VOLUME /var/lib/firebird/2.5/backup

# SSH Installieren
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:mmbbs' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Java installieren
RUN     apt-get install -y openjdk-8-jdk

# glassfish installieren
ENV GLASSFISH_PKG=glassfish-4.0-web.zip \
    GLASSFISH_URL=http://download.java.net/glassfish/4.0/release/glassfish-4.0-web.zip \
    GLASSFISH_HOME=/glassfish4 \
    PATH=$PATH:/glassfish4/bin \
    PASSWORD=mmbbs

# Install packages, download and extract GlassFish
# Setup password file
# Enable DAS
RUN apt-get -qq -y install wget unzip && \
    apt-get -qq -y install wget unzip && \
    wget --no-check-certificate $GLASSFISH_URL && \
    unzip -o $GLASSFISH_PKG && \
    rm -f $GLASSFISH_PKG && \    
    echo "--- Setup the password file ---" && \
    echo "AS_ADMIN_PASSWORD=" > /tmp/glassfishpwd && \
    echo "AS_ADMIN_NEWPASSWORD=${PASSWORD}" >> /tmp/glassfishpwd  && \
    echo "--- Enable DAS, change admin password, and secure admin access ---" && \
    asadmin --user=admin --passwordfile=/tmp/glassfishpwd change-admin-password --domain_name domain1 && \
    asadmin start-domain && \
    echo "AS_ADMIN_PASSWORD=${PASSWORD}" > /tmp/glassfishpwd && \
    asadmin --user=admin --passwordfile=/tmp/glassfishpwd enable-secure-admin && \
    asadmin --user=admin stop-domain 
    

# diklabu installieren

RUN  mkdir /home/diklabu && \
        cd /home/diklabu && \
        mkdir temp && \
        git clone https://github.com/jtuttas/diklabu.git && \        
        mv diklabu/Diklabu/lib/* /glassfish4/glassfish/domains/domain1/lib/ext/  && \
        mv diklabu/Diklabu/doc/config.json /glassfish4/glassfish/domains/domain1/ && \
        chmod +xxx diklabu/Diklabu/start.sh && \        
        cp /glassfish4/glassfish/domains/domain1/lib/ext/jaybird-full-2.2.8.jar /glassfish4/glassfish/domains/domain1/lib/ && \
        asadmin --user=admin start-domain && \
        /glassfish4/bin/asadmin create-jdbc-connection-pool --user admin --passwordfile=/tmp/glassfishpwd --datasourceclassname org.firebirdsql.pool.FBSimpleDataSource --restype javax.sql.DataSource --property user=sysdba:password=masterkey:DatabaseName=/var/lib/firebird/2.5/data/diklabu.GDB:ServerName=localhost:port=3050:encoding=ISO8859_1:characterEncoding=ISO8859_1:characterSetResults=ISO8859_1 connectionPoolKlassenbuch && \
        /glassfish4/bin/asadmin create-jdbc-resource --user admin --passwordfile=/tmp/glassfishpwd --connectionpoolid connectionPoolKlassenbuch jdbc/myDatasource && \
        asadmin --user=admin stop-domain 

RUN    cd /var/lib/firebird/2.5/data && \
       chown -R firebird *  && \
       chgrp -R firebird * && \
       chmod +664 * && \
       ls -la
        


EXPOSE 8080 4848 8181 3050 22
#ENTRYPOINT /home/diklabu/diklabu/Diklabu/start.sh
#ENTRYPOINT /home/diklabu/diklabu/Diklabu/start.sh
#cmd     ["/home/diklabu/diklabu/Diklabu/start.sh", "-n"]
#cmd /home/diklabu/diklabu/Diklabu/start.sh
CMD bash -C '/home/diklabu/diklabu/Diklabu/start.sh';'bash'