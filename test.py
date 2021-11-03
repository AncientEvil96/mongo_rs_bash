from pymongo import MongoClient

host = 'mongo_rs_1,mongo_rs_2,mongo_rs_3'
tlsCertificateKeyFile = '192.168.1.116'
tlsCAFile = 'mongoCA.pem'
username = 'root'
password = 'root'

with MongoClient(
    host,
    username=username,
    password=password,
    replicaSet = True,
    tls = True,
    tlsCertificateKeyFile=tlsCertificateKeyFile,
    tlsCAFile=tlsCAFile
) as conn:
    db = conn['test']
    connection = db['test']

    connection