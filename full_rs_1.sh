#!/bin/bash

number=1

if [ -n "$1" ]; then
    number=$1
fi

bash new_srv_mongo.sh -rm -new_srv mongo_rs_$number -ip 172.16.238.2 -port 27001 -net
bash new_srv_mongo.sh -rm -new_srv mongo_rs_arb_$number -ip 172.16.238.3 -port 27002