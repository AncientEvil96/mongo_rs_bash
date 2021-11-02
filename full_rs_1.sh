#!/bin/bash

mkdir -m 777 -p docker/ssl

cp mongoCA.pem docker/ssl

bash new_srv_mongo.sh -rm -new_srv mongo_rs_2 -rs_add mongo_rs_1 -ip 172.16.238.3
bash new_srv_mongo.sh -rm -rs_arb -new_srv mongo_rs_arb_1 -rs_add mongo_rs_1 -ip 172.16.238.5