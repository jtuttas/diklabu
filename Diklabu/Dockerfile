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
ENV GLASSFISH_PKG=glassfish-4.1.1-web.zip \
    GLASSFISH_URL=http://download.oracle.com/glassfish/4.1.1/release/glassfish-4.1.1-web.zip \
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
    asadmin --user=admin stop-domain && \
    rm /tmp/glassfishpwd

# diklabu installieren

RUN  mkdir /home/diklabu && \
        cd /home/diklabu && \
        mkdir temp && \
        git clone https://github.com/jtuttas/diklabu.git && \
        mv diklabu/Diklabu/lib/ /glassfish4/glassfish/domains/domain1/lib/ext/  && \
        mv diklabu/Diklabu/doc/config.json /glassfish4/glassfish/domains/domain1/ && \
        chmod +xxx diklabu/Diklabu/start.sh 

RUN isql-fb -i /home/diklabu/diklabu/Diklabu/Sql_buils.sql        

EXPOSE 8080 4848 8181 3050 22
#ENTRYPOINT /home/diklabu/diklabu/Diklabu/start.sh
CMD bash -C '/home/diklabu/diklabu/Diklabu/start.sh';'bash'
