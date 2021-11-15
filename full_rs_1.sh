#!/bin/bash

number=1

if [ -n "$1" ]; then
    number=$1
fi

docker stop mongo_rs_$number
docker rm mongo_rs_$number
sudo rm -r $path/mongo_rs_$number

docker stop mongo_rs_arb_$number
docker rm mongo_rs_arb_$number
sudo rm -r $path/mongo_rs_arb_$number
docker volume prune

bash new_srv_mongo.sh -rm -new_srv mongo_rs_$number -ip 172.16.238.2 -port 27001 -net
bash new_srv_mongo.sh -rm -new_srv mongo_rs_arb_$number -ip 172.16.238.3 -port 27002

echo -e "172.16.238.2\tmongo_rs_$number >> /etc/hosts"
echo -e "172.16.238.3\tmongo_rs_arb_$number >> /etc/hosts"
echo -e "192.168.2.172\tmongo_rs_0 >> /etc/hosts"
echo -e "192.168.2.178\tmongo_rs_2 mongo_rs_arb_2 >> /etc/hosts"