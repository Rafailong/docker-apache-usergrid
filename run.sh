#!/bin/bash
#
# Based on https://github.com/tutumcloud/tutum-docker-tomcat
#


echo "Adding ROOT.war to /usergrid"
pushd /usergrid/ROOT
jar xvf ./ROOT.war
rm ROOT.war
jar -xf ./WEB-INF/lib/usergrid-config-2.1.0-SNAPSHOT.jar

# # make changes
echo "Custom Cassandra URL: $CASSANDRA_URL"
echo "Custom elasticsearch host: $ELASTICSEARCH_HOST"
echo "Custom elasticsearch port: $ELASTICSEARCH_PORT"

cat /dev/null > ./usergrid-default.properties
cat /usergrid/usergrid-deploy.properties > ./usergrid-default.properties

# make jar of updated usergrid properties
jar cf usergrid-config-2.1.0-SNAPSHOT.jar usergrid-default.properties

cp usergrid-config-2.1.0-SNAPSHOT.jar ./WEB-INF/lib/
rm usergrid-config-2.1.0-SNAPSHOT.jar usergrid-default.properties

# make war
echo "Making ROOT.war"
jar -cvf ROOT.war .
mv ROOT.war ../
cd ../

rm -R ROOT/*
rmdir ROOT

echo "Adding ROOT.war to tomcat webapps"
cp ROOT.war /usr/share/tomcat7/webapps

popd

ln -s /usr/share/tomcat7/webapps/ /etc/tomcat7/webapps

if [ ! -f ${TOMCAT_CONFIGURATION_FLAG} ]; then
    /usergrid/create_tomcat_admin_user.sh
fi

exec /usr/share/tomcat7/bin/catalina.sh run

# docker run -d --name usergrid --link elasticsearch:elasticsearch --link cassandra:cassandra -p 8080:8080 -p 8443:8443 -t usergrid -e "CASSANDRA_URL=172.17.0.73:9160" -e "ELASTICSEARCH_HOST=172.17.0.73" -e "ELASTICSEARCH_PORT=9300"
