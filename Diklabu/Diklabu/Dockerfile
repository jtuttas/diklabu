# BUILD Example
# docker build Diklabu -t "diklabu:neu"
# START Example
# docker run -v d:/Temp:/var/lib/firebird/3.0/data -v d:/Temp:/etc/diklabu -i -t -p 8080:8080 -p 3051:3050 -p 222:22  diklabu

FROM ubuntu:22.04
MAINTAINER Joerg Tuttas <tuttas@mmbbs.de>
ENV DEBIAN_FRONTEND noninteractive
ENV _JAVA_OPTIONS="-Djdk.tls.client.protocols=TLSv1.2"

#Install firebird 3.0
RUN apt-get update && \
    apt-get -y upgrade && \
	apt-get install -y firebird3.0-server firebird3.0-utils && \
  sed -ri 's/RemoteBindAddress = localhost/RemoteBindAddress = /g' /etc/firebird/3.0/firebird.conf && \
  echo "" >> /etc/firebird/3.0/firebird.conf && \
  echo "# Custom configuration for legacy database support" >> /etc/firebird/3.0/firebird.conf && \
  echo "AuthServer = Legacy_Auth, Srp" >> /etc/firebird/3.0/firebird.conf && \
  echo "AuthClient = Legacy_Auth, Srp" >> /etc/firebird/3.0/firebird.conf && \
  echo "UserManager = Legacy_UserManager, Srp" >> /etc/firebird/3.0/firebird.conf && \
  echo "WireCrypt = Disabled" >> /etc/firebird/3.0/firebird.conf && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# forward logs to docker log collector
#RUN ln -sf /dev/stdout /var/log/firebird/firebird3.0.log

RUN mkdir /etc/diklabu
VOLUME /etc/diklabu

#install Utils
RUN apt-get -qq update && \
       apt-get -qq -y install nano && \
       apt-get -qq -y install git && \
       apt-get -qq -y install mc  
   #     apt-get -qq -y install net-tools 

VOLUME /var/lib/firebird/3.0/data

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
RUN     apt-get install -y openjdk-11-jdk

# Payara Server installieren (Version 5 für javax.servlet Kompatibilität)
ENV PAYARA_PKG=payara-5.2022.5.zip \
    PAYARA_URL=https://nexus.payara.fish/repository/payara-community/fish/payara/distributions/payara/5.2022.5/payara-5.2022.5.zip \
    PAYARA_HOME=/opt/payara5 \
    PATH=$PATH:/opt/payara5/bin \
    PASSWORD=mmbbs

# Install packages, download and extract Payara Server
# Setup password file
# Enable DAS
RUN apt-get -qq -y install wget unzip && \
    wget $PAYARA_URL && \
    unzip -o $PAYARA_PKG -d /opt && \
    rm -f $PAYARA_PKG && \    
    echo "--- Setup the password file ---" && \
    echo "AS_ADMIN_PASSWORD=" > /tmp/payarapwd && \
    echo "AS_ADMIN_NEWPASSWORD=${PASSWORD}" >> /tmp/payarapwd  && \
    echo "--- Enable DAS, change admin password, and secure admin access ---" && \
    ${PAYARA_HOME}/bin/asadmin --user=admin --passwordfile=/tmp/payarapwd change-admin-password --domain_name domain1 && \
    ${PAYARA_HOME}/bin/asadmin start-domain && \
    echo "AS_ADMIN_PASSWORD=${PASSWORD}" > /tmp/payarapwd && \
    ${PAYARA_HOME}/bin/asadmin --user=admin --passwordfile=/tmp/payarapwd enable-secure-admin && \
    ${PAYARA_HOME}/bin/asadmin --user=admin stop-domain 
    

# diklabu installieren

RUN  mkdir /home/diklabu && \
        echo "klone diklabu............!!." && \
        cd /home/diklabu && \
        mkdir temp && \
        git clone https://github.com/jtuttas/diklabu.git && \
        mkdir -p ${PAYARA_HOME}/glassfish/domains/domain1/lib/ && \
        cp -r diklabu/Diklabu/lib/* ${PAYARA_HOME}/glassfish/domains/domain1/lib/  && \
        mkdir /home/diklabu/atest && \
        mkdir /home/diklabu/images && \
        mkdir /home/diklabu/templates && \
        ln -s /etc/diklabu/config.json ${PAYARA_HOME}/glassfish/domains/domain1/config.json && \
        mkdir -p /home/diklabu/diklabu/Diklabu/dist

# Copy the pre-built WAR file from local dist folder (relative to build context)
COPY dist/Diklabu.war /home/diklabu/diklabu/Diklabu/dist/Diklabu.war

# Copy local start.sh to override the one from git
COPY Diklabu/start.sh /home/diklabu/diklabu/Diklabu/Diklabu/start.sh
RUN sed -i 's/\r$//' /home/diklabu/diklabu/Diklabu/Diklabu/start.sh && \
    chmod +x /home/diklabu/diklabu/Diklabu/Diklabu/start.sh

# Copy local web.xml to override the one from git
COPY web/WEB-INF/web.xml /home/diklabu/diklabu/Diklabu/web/WEB-INF/web.xml

RUN  ${PAYARA_HOME}/bin/asadmin --user=admin start-domain && \
    ${PAYARA_HOME}/bin/asadmin create-jdbc-connection-pool --user admin --passwordfile=/tmp/payarapwd --datasourceclassname org.firebirdsql.ds.FBSimpleDataSource --restype javax.sql.DataSource connectionPoolKlassenbuch && \
        ${PAYARA_HOME}/bin/asadmin set --user admin --passwordfile=/tmp/payarapwd resources.jdbc-connection-pool.connectionPoolKlassenbuch.property.serverName=localhost && \
        ${PAYARA_HOME}/bin/asadmin set --user admin --passwordfile=/tmp/payarapwd resources.jdbc-connection-pool.connectionPoolKlassenbuch.property.portNumber=3050 && \
        ${PAYARA_HOME}/bin/asadmin set --user admin --passwordfile=/tmp/payarapwd resources.jdbc-connection-pool.connectionPoolKlassenbuch.property.databaseName=/var/lib/firebird/3.0/data/KLASSENBUCH.GDB && \
        ${PAYARA_HOME}/bin/asadmin set --user admin --passwordfile=/tmp/payarapwd resources.jdbc-connection-pool.connectionPoolKlassenbuch.property.userName=SYSDBA && \
        ${PAYARA_HOME}/bin/asadmin set --user admin --passwordfile=/tmp/payarapwd resources.jdbc-connection-pool.connectionPoolKlassenbuch.property.password=masterkey && \
        ${PAYARA_HOME}/bin/asadmin set --user admin --passwordfile=/tmp/payarapwd resources.jdbc-connection-pool.connectionPoolKlassenbuch.property.charSet=ISO8859_1 && \
        ${PAYARA_HOME}/bin/asadmin set --user admin --passwordfile=/tmp/payarapwd resources.jdbc-connection-pool.connectionPoolKlassenbuch.property.type=PURE_JAVA && \
        ${PAYARA_HOME}/bin/asadmin set --user admin --passwordfile=/tmp/payarapwd resources.jdbc-connection-pool.connectionPoolKlassenbuch.property.sqlDialect=3 && \
        ${PAYARA_HOME}/bin/asadmin set --user admin --passwordfile=/tmp/payarapwd resources.jdbc-connection-pool.connectionPoolKlassenbuch.property.wireCrypt=DISABLED && \
        ${PAYARA_HOME}/bin/asadmin set --user admin --passwordfile=/tmp/payarapwd "resources.jdbc-connection-pool.connectionPoolKlassenbuch.property.authPlugins=Legacy_Auth,Srp256" && \
        ${PAYARA_HOME}/bin/asadmin create-jdbc-resource --user admin --passwordfile=/tmp/payarapwd --connectionpoolid connectionPoolKlassenbuch jdbc/myDatasourceKlassenbuch && \
        ${PAYARA_HOME}/bin/asadmin --user=admin stop-domain 

RUN    cd /var/lib/firebird/3.0/data && \
       chown -R firebird *  && \
       chgrp -R firebird * && \
       chmod +664 * && \
       ls -la
	   	
VOLUME 	/home/diklabu/atest
VOLUME  /home/diklabu/images
VOLUME	/home/diklabu/templates

# Install OpenSSL for certificate conversion
RUN apt-get -qq update && apt-get -qq -y install openssl

EXPOSE 8080 8443 4848 8181 3050 22
#ENTRYPOINT /home/diklabu/diklabu/Diklabu/start.sh
#ENTRYPOINT /home/diklabu/diklabu/Diklabu/start.sh
#cmd     ["/home/diklabu/diklabu/Diklabu/start.sh", "-n"]
#cmd /home/diklabu/diklabu/Diklabu/start.sh
CMD bash -C '/home/diklabu/diklabu/Diklabu/Diklabu/start.sh';'bash'