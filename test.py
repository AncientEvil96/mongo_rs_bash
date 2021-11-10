from pymongo import MongoClient

try:
    with MongoClient(
            '192.168.2.172:27017',
            username='root',
            password='root',
            replicaSet='rs0',
            tls=True,
            tlsCertificateKeyFile='192.168.1.166.pem',
            tlsCAFile='mongoCA.pem',
            connectTimeoutMS=3000,
            serverSelectionTimeoutMS=3000
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
except Exception as err:
    print(err)