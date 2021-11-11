#!/bin/bash

bash new_srv_mongo.sh -rm -new_srv mongo_rs_1 -rs_add mongo_rs_0 -ip 172.16.238.2 -port 27001
bash new_srv_mongo.sh -rm -rs_arb -new_srv mongo_rs_arb_1 -rs_add mongo_rs_0 -ip 172.16.238.3 -port 27002