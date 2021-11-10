#!/bin/bash

bash new_srv_mongo.sh -rm -new_srv mongo_rs_1 -rs_add 192.168.2.172 -ip 172.16.238.2 -p 27001 -ip_srv 192.168.2.172
bash new_srv_mongo.sh -rm -rs_arb -new_srv mongo_rs_arb_1 -rs_add 192.168.2.172 -ip 172.16.238.3 -p 27002 -ip_srv 192.168.2.172