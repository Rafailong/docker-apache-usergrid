################################################################################
# Docker file to run Apache usergrid
# Based on Ubuntu Image
################################################################################

FROM ubuntu:latest

MAINTAINER Rafael Avila <rafa.avim@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV TOMCAT_CONFIGURATION_FLAG /usergrid/.tomcat_admin_created

# Install commong packages
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-get install -y python-software-properties
RUN apt-add-repository ppa:webupd8team/java
RUN apt-get update

# Install utilities
RUN apt-get install -y wget pwgen unzip

# Install Oracle JDK 8 and Apache Maven
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer
RUN apt-get install -y maven
RUN apt-get install -y tomcat7

# Configure basic stuff, nothing important.
RUN mkdir /usergrid
WORKDIR /usergrid

ADD create_tomcat_admin_user.sh /usergrid/create_tomcat_admin_user.sh
ADD run.sh /usergrid/run.sh
RUN chmod +x /usergrid/*.sh
RUN ln -s /etc/tomcat7/ /usr/share/tomcat7/conf

# Just to suppress tomcat warnings
RUN mkdir -p /usr/share/tomcat7/common/classes; \
mkdir -p /usr/share/tomcat7/server/classes; \
mkdir -p /usr/share/tomcat7/shared/classes; \
mkdir -p /usr/share/tomcat7/webapps; \
mkdir -p /usr/share/tomcat7/temp

RUN mkdir /temp
WORKDIR /temp

# Download and compile usergrid
RUN wget https://github.com/apache/usergrid/archive/master.zip
RUN unzip master.zip

WORKDIR /temp/usergrid-master/sdks/java
RUN mvn clean install -DskipTests=true

WORKDIR /temp/usergrid-master/stack
RUN mvn clean install -DskipTests=true

# Deploy WAR file
RUN mkdir -p /usergrid/ROOT
RUN cp /temp/usergrid-master/stack/rest/target/ROOT.war /usergrid/ROOT/

# Expose ports
EXPOSE 8080

# Run usergrid
WORKDIR /usergrid
ENTRYPOINT ./run.sh
