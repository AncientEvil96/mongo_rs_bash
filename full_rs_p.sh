#!/bin/bash

mkdir -m 777 -p docker/ssl

cp mongoCA.pem docker/ssl

bash new_srv_mongo.sh -rm -new_srv mongo_rs_1 -rs_p -ip 172.16.238.2