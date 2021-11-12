#!/bin/bash

bash new_srv_mongo.sh -rm -new_srv mongo_rs_0 -rs_p -ip 172.16.238.2 -net

number=$1

if [ $number = 1]; then
    docker exec -it mongo_rs_0 mongosh \
        --tls \
        --host mongo_rs_0 \
        --tlsCertificateKeyFile /etc/ssl/mongo_rs_0.pem \
        --tlsCAFile /etc/ssl/mongoCA.pem -u root -p root \
        --quiet --eval "rs.addArb('mongo_rs_arb_2:27002')"
    docker exec -it mongo_rs_0 mongosh \
        --tls \
        --host mongo_rs_0 \
        --tlsCertificateKeyFile /etc/ssl/mongo_rs_0.pem \
        --tlsCAFile /etc/ssl/mongoCA.pem -u root -p root \
        --quiet --eval "rs.addArb('mongo_rs_arb_1:27002')"
    docker exec -it mongo_rs_0 mongosh \
        --tls \
        --host mongo_rs_0 \
        --tlsCertificateKeyFile /etc/ssl/mongo_rs_0.pem \
        --tlsCAFile /etc/ssl/mongoCA.pem -u root -p root \
        --quiet --eval "rs.add('mongo_rs_1:27001')"
    docker exec -it mongo_rs_0 mongosh \
        --tls \
        --host mongo_rs_0 \
        --tlsCertificateKeyFile /etc/ssl/mongo_rs_0.pem \
        --tlsCAFile /etc/ssl/mongoCA.pem -u root -p root \
        --quiet --eval "rs.add('mongo_rs_2:27001')"
fi