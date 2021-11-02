
#!/bin/bash

path=docker
config=mongod.conf
ddd=0
rs_p=0
rs_arb=0
subnet=172.16.238.0/24
user=root
pass=root


while [ -n "$1" ]
do
case "$1" in
-h) 
echo ""
echo -e "-d\t\tgeneral directory (defaut \"docker)\""
echo -e "-rm\t\tdeleted old docker containers + files"
echo -e "-new_srv\tnew server name"
echo -e "-conf\t\tmongod.conf full or relative path if the file is not in the root folder"
echo -e "-rs_p\t\tinitiate replicaSet"
echo -e "-rs_add\t\tname primary srv to add server"
echo -e "-rs_arb\t\tadd arbiter to -rs_add"
echo -e "-ip\t\tfrom srv: any static unoccupied ip address in the range of mongo_rs (defaut $subnet)"
echo -e "-client\t\tip client (the CA file must exist to docker/ssl)"
echo -e "-u\t\tuser name (defaut \"root\")"
echo -e "-p\t\tpassword (defaut \"root\")"
echo ""
exit;;
-rm) ddd=1;;
-new_srv) srv=$2;;
-d) path=$2;;
-conf) config=$2;;
-rs_add) rs_add=$2;;
-rs_arb) rs_arb=1;;
-rs_p) rs_p=1;;
-subnet) subnet=$2;;
-client) client=$2;;
-ip) ip=$2;;
-u) user=$2;;
-p) pass=$2;;
esac
shift
done

if [ -n "$client" ]; then 
    echo -e "\ncreate pem from client $path/ssl\n"
    openssl genrsa -out $path/ssl/$client.key 4096
    openssl req -new -key $path/ssl/$client.key -out $path/ssl/$client.csr -subj "/C=RU/ST=RT/L=NCH/O=VPROK/OU=IT/CN=$client"
    openssl x509 -req -in $path/ssl/$client.csr -CA $path/ssl/mongoCA.pem -CAcreateserial -out $path/ssl/$client.crt -days 365
    cat $path/ssl/$client.key $path/ssl/$client.crt > $path/ssl/$client.pem
    rm $path/ssl/$client.key $path/ssl/$client.crt $path/ssl/$client.csr 
    exit
fi

if [ -z "$ip" ]; then 
    echo "parameter missing -ip"
    exit
fi

if [ -z "$srv" ]; then 
    echo "parameter missing -new_srv"
    exit
fi

if [ $rs_arb = 1 ] && [ -z "$rs_add" ]; then 
    echo "parameter missing -rs_add"
    exit
fi

if [ -z "$rs_add" ] && [ $rs_p = 0 ]; then 
    echo "parameter missing -rs_add"
    exit
fi

if [ -z "$rs_add" ] && [ $rs_p = 1 ]; then 
    rs_add=$srv
fi

if [ $rs_p = 1 ] && [ -z "$ip" ]; then 
    echo "parameter missing -ip"
    exit
fi

if [ $ddd = 1 ]; then 
    echo -e "\ndeleted old\n"
    docker stop $srv
    docker rm $srv
    sudo rm -r $path/$srv
    docker volume rm $srv
    # docker network rm mongo_rs
fi

if [ $rs_p = 1 ]; then

    docker network create --subnet=$subnet mongo_rs

    mkdir -m 777 -p docker/ssl

    sudo chmod -R 777 docker/*

    echo "корневой сертификат"
    openssl genrsa -out $path/ssl/mongoCA.key 4096
    openssl req -x509 -new -key $path/ssl/mongoCA.key -days 10000 -out $path/ssl/mongoCA.crt -subj "/C=RU/ST=RT/L=NCH/O=VPROK/OU=IT/CN=mongoCA"
    cat $path/ssl/mongoCA.key $path/ssl/mongoCA.crt > $path/ssl/mongoCA.pem
    rm $path/ssl/mongoCA.key $path/ssl/mongoCA.crt
fi

echo -e "\ncreate dir $path/$srv\n"
mkdir -m 777 -p $path/$srv

echo -e "\ncreate pem from srv $path/ssl\n"
openssl genrsa -out $path/ssl/$srv.key 4096
openssl req -new -key $path/ssl/$srv.key -out $path/ssl/$srv.csr -subj "/C=RU/ST=RT/L=NCH/O=VPROK/OU=IT/CN=$srv"
openssl x509 -req -in $path/ssl/$srv.csr -CA $path/ssl/mongoCA.pem -CAcreateserial -out $path/ssl/$srv.crt -days 10000
cat $path/ssl/$srv.key $path/ssl/$srv.crt > $path/ssl/$srv.pem
rm $path/ssl/$srv.key $path/ssl/$srv.crt $path/ssl/$srv.csr

echo -e "\ncreate dir $path/$srv/var/lib + $path/$srv/var/log\n"
mkdir -m 777 -p $path/$srv/var/lib
mkdir -m 777 -p $path/$srv/var/log

echo -e "\ncopy config $config\n"
cat $config > $path/$srv/mongod.conf
sed -i "s/mongo1.pem/$srv.pem/g" $path/$srv/mongod.conf

sudo chmod -R 777 $path/$srv

echo -e "\nbuilt image\n"
docker build -t mongo_rs .

pwd_dir=`pwd`

docker run -d \
--hostname $srv \
--ip $ip \
--network mongo_rs \
--name $srv \
--restart=always \
--env MONGO_INITDB_ROOT_USERNAME=root \
--env MONGO_INITDB_ROOT_PASSWORD=root \
-v $pwd_dir/$path/$srv/mongod.conf:/etc/mongod.conf:rw \
-v $pwd_dir/$path/ssl/:/etc/ssl:rw \
-v $pwd_dir/$path/$srv/var/lib/:/var/lib/mongodb \
-v $pwd_dir/$path/$srv/var/log/:/var/log/mongodb \
mongo_rs \
mongod --config /etc/mongod.conf

sed -i 's/# //g' $path/$srv/mongod.conf

sleep 2

echo "restart"
docker restart $srv

if [ $rs_p = 1 ]; then
    sleep 5
    docker exec -it $rs_add mongosh \
    --tls \
    --host $rs_add \
    --tlsCertificateKeyFile /etc/ssl/$rs_add.pem \
    --tlsCAFile /etc/ssl/mongoCA.pem \
    -u $user -p $pass \
    --quiet --eval "rs.initiate()"
elif [ -n "$rs_add" ] && [ $rs_arb = 0 ]; then
    sleep 5
    docker exec -it $rs_add mongosh \
    --tls \
    --host $rs_add \
    --tlsCertificateKeyFile /etc/ssl/$rs_add.pem \
    --tlsCAFile /etc/ssl/mongoCA.pem -u $user -p $pass \
    --quiet --eval "rs.add('$srv:27017')"
    docker exec -it $rs_add mongosh \
    --tls \
    --host $rs_add \
    --tlsCertificateKeyFile /etc/ssl/$rs_add.pem \
    --tlsCAFile /etc/ssl/mongoCA.pem -u $user -p $pass \
    --quiet --eval "db.adminCommand({ 'setDefaultRWConcern': 1, 'defaultWriteConcern': { 'w': 1 } })"
elif [ $rs_arb = 1 ]; then
    sleep 5
    docker exec -it $rs_add mongosh \
    --tls \
    --host $rs_add \
    --tlsCertificateKeyFile /etc/ssl/$rs_add.pem \
    --tlsCAFile /etc/ssl/mongoCA.pem -u $user -p $pass \
    --quiet --eval "rs.addArb({'$srv:27017'})"
fi
