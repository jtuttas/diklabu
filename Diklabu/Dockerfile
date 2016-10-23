FROM ubuntu:gffbssh
#COPY web/img/portfolio/1.jpg /glassfish4/glassfish/domains/domain1
MAINTAINER Joerg Tuttas <tuttas@mmbbs.de>
RUN echo 'root:mmbbs' | chpasswd
ENTRYPOINT service firebird2.5-superclassic start && /app/glassfish4/bin/asadmin start-domain && service ssh restart && bash
expose 8080 4848 8181 3050 22