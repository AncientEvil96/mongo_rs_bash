from pymongo import MongoClient

host = '192.168.2.172:27017'
tlsCertificateKeyFile = '192.168.1.166.pem'
tlsCAFile = 'mongoCA.pem'
username = 'root'
password = 'root'

with MongoClient(
        host,
        username=username,
        password=password,
        replicaSet='rs0',
        tls=True,
        tlsCertificateKeyFile=tlsCertificateKeyFile,
        tlsCAFile=tlsCAFile
) as conn:
    db = conn['test']
    connection = db['test']

    for i in range(1, 1000000):
        if i % 2 == 0:
            connection.insert_one({'name': 'Tom', 'type': 'cat'})
            print(connection.count_documents({'name': 'Tom'}))
        else:
            connection.insert_one({'name': 'Jerry', 'type': 'mouse'})
            print(connection.count_documents({'name': 'Jerry'}))
