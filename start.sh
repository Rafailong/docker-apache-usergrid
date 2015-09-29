#! /bin/bash

docker run -d --name usergrid -p 8080:8080 -p 8443:8443 --link cassandra:cassandra --link elasticsearch:elasticsearch -e CASSANDRA_URL=172.17.0.1:9160 -e ELASTICSEARCH_HOST=172.17.0.2 -e ELASTICSEARCH_PORT=9300 usergrid
