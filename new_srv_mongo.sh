
#!/bin/bash

path=docker
config=mongod.conf
ddd=0
rs_p=0
rs_arb=0
ca=0
subnet=172.16.238.0/24
user=root
pass=root
port=27017
net=0
build=0



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
echo -e "-port\t\tport (defaut \"$port)\""
echo -e "-ip\t\tfrom srv: any static unoccupied ip address in the range of mongo_rs (defaut $subnet)"
echo -e "-client\t\tip client (the CA file must exist to docker/ssl)"
echo -e "-ca\t\tcreate ca file"
echo -e "-u\t\tuser name (defaut \"root\")"
echo -e "-p\t\tpassword (defaut \"root\")"
echo ""
exit;;
-rm) ddd=1;;
-host) host=$2;;
-port) port=$2;;
-net) net=1;;
-new_srv) srv=$2;;
-d) path=$2;;
-conf) config=$2;;
-rs_add) rs_add=$2;;
-rs_arb) rs_arb=1;;
-rs_p) rs_p=1;;
-port) port=$2;;
-ip) ip=$2;;
-subnet) subnet=$2;;
-client) client=$2;;
-build) build=1;;
-ca) ca=1;;
-u) user=$2;;
-p) pass=$2;;
esac
shift
done

if [ $build = 1 ]; then 
    echo -e "\nbuild image\n"
    docker build -t mongo_rs .
fi

if [ $ddd = 1 ]; then 
    echo -e "\ndeleted old\n"
    docker stop $srv
    docker rm $srv
    sudo rm -r $path/$srv
    docker volume rm $srv
    # docker network rm mongo_rs
fi

echo -e "\ncreate dir $path/$srv\n"
sudo mkdir -m 777 -p $path/$srv
sudo chmod -R 777 $path/ssl

if [ $net = 1 ]; then
    docker network create --subnet=$subnet mongo_rs
fi

if [ $ca = 1 ]; then

    echo "корневой сертификат"
    sudo openssl genrsa -out $path/ssl/mongoCA.key 4096
    sudo openssl req -x509 -new -key $path/ssl/mongoCA.key -days 10000 -out $path/ssl/mongoCA.crt -subj "/C=RU/ST=RT/L=NCH/O=VPROK/OU=IT/CN=mongoCA"
    cat $path/ssl/mongoCA.key $path/ssl/mongoCA.crt > $path/ssl/mongoCA.pem
    sudo rm $path/ssl/mongoCA.key $path/ssl/mongoCA.crt

else
    echo "копируем сертификат"
    sudo cp mongoCA.pem $path/ssl/
fi

if [ -n "$client" ]; then 
    echo -e "\ncreate pem from client $path/ssl\n"
    sudo openssl genrsa -out $path/ssl/$client.key 4096
    sudo openssl req -new -key $path/ssl/$client.key -out $path/ssl/$client.csr -subj "/C=RU/ST=RT/L=NCH/O=VPROK/OU=IT/CN=$client"
    sudo openssl x509 -req -in $path/ssl/$client.csr -CA $path/ssl/mongoCA.pem -CAcreateserial -out $path/ssl/$client.crt -days 365
    cat $path/ssl/$client.key $path/ssl/$client.crt > $path/ssl/$client.pem
    sudo rm $path/ssl/$client.key $path/ssl/$client.crt $path/ssl/$client.csr
fi

if [ -n "$rs_add" ] && [ $rs_arb = 0 ]; then
    
    sleep 10
    docker exec -it $rs_add mongosh \
    --tls \
    --host $rs_add \
    --tlsCertificateKeyFile /etc/ssl/$rs_add.pem \
    --tlsCAFile /etc/ssl/mongoCA.pem -u $user -p $pass \
    --quiet --eval "rs.add('$srv:$port')"
    exit
elif [ $rs_arb = 1 ]; then
    
    sleep 10
    docker exec -it $rs_add mongosh \
    --tls \
    --host $rs_add \
    --tlsCertificateKeyFile /etc/ssl/$rs_add.pem \
    --tlsCAFile /etc/ssl/mongoCA.pem -u $user -p $pass \
    --quiet --eval "rs.addArb('$srv:$port')"
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

# if [ $rs_arb = 1 ] && [ -z "$rs_add" ]; then 
#     echo "parameter missing -rs_add"
#     exit
# fi

# if [ -z "$rs_add" ] && [ $rs_p = 0 ]; then 
#     echo "parameter missing -rs_add"
#     exit
# fi

if [ $rs_p = 1 ]; then 
    rs_add=$srv
fi

if [ $rs_p = 1 ] && [ -z "$ip" ]; then 
    echo "parameter missing -ip"
    exit
fi

if [ $net = 1 ]; then
    docker network create --subnet=$subnet mongo_rs
fi

echo -e "\ncreate dir $path/$srv/var/lib + $path/$srv/var/log\n"
sudo mkdir -m 777 -p $path/$srv/var/lib
sudo mkdir -m 777 -p $path/$srv/var/log

echo -e "\ncopy config $config\n"
cat $config > $path/$srv/mongod.conf
sudo sed -i "s/mongo1.pem/$srv.pem/g" $path/$srv/mongod.conf

sudo chmod -R 777 $path/$srv

pwd_dir=`pwd`

docker run -d \
--hostname $srv \
--ip $ip \
-p $port:27017 \
--network mongo_rs \
--name $srv \
--restart=always \
--env MONGO_INITDB_ROOT_USERNAME=$user \
--env MONGO_INITDB_ROOT_PASSWORD=$pass \
-v $pwd_dir/$path/$srv/mongod.conf:/etc/mongod.conf:rw \
-v $pwd_dir/$path/ssl/:/etc/ssl:rw \
-v $pwd_dir/$path/$srv/var/lib/:/var/lib/mongodb \
-v $pwd_dir/$path/$srv/var/log/:/var/log/mongodb \
mongo_rs \
mongod --config /etc/mongod.conf

sudo sed -i 's/# //g' $path/$srv/mongod.conf

sleep 5

echo "restart"
docker restart $srv

if [ $rs_p = 1 ]; then
    
    sleep 10
    docker exec -it $rs_add mongosh \
    --tls \
    --host $rs_add \
    --tlsCertificateKeyFile /etc/ssl/$rs_add.pem \
    --tlsCAFile /etc/ssl/mongoCA.pem \
    -u $user -p $pass \
    --quiet --eval "rs.initiate()"

    sleep 5
    
     docker exec -it $rs_add mongosh \
    --tls \
    --host $rs_add \
    --tlsCertificateKeyFile /etc/ssl/$rs_add.pem \
    --tlsCAFile /etc/ssl/mongoCA.pem -u $user -p $pass \
    --quiet --eval "db.adminCommand({ 'setDefaultRWConcern': 1, 'defaultWriteConcern': { 'w': 1 } })"
    exit
fi