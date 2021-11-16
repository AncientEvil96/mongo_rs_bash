#!/bin/bash

bash new_srv_mongo.sh -rm -new_srv mongo_rs_0 -rs_p -ip 172.16.238.2 -net -ca -client mongo_rs_0
# bash new_srv_mongo.sh -rm -new_srv mongo_rs_1 -ip 172.16.238.3 -port 27001
# bash new_srv_mongo.sh -rm -new_srv mongo_rs_arb_1 -ip 172.16.238.4 -port 27002
# bash new_srv_mongo.sh -rm -new_srv mongo_rs_2 -ip 172.16.238.5 -port 27003
# bash new_srv_mongo.sh -rm -new_srv mongo_rs_arb_2 -ip 172.16.238.6 -port 27004