#!/bin/bash

add=0


while [ -n "$1" ]
do
case "$1" in
-h) 
echo ""
echo -e "-d\t\tgeneral directory (defaut \"docker)\""
echo ""
exit;;
-add) add=1;;
esac
shift
done


bash new_srv_mongo.sh -rm -new_srv mongo_rs_0 -rs_p -ip 172.16.238.2 -net

if [ $add = 1]; then
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