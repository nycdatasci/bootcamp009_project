from kafka import KafkaProducer
import csv
import json
import time

# Connect to Kafka
producer = KafkaProducer(bootstrap_servers='ec2-54-173-251-232.compute-1.amazonaws.com:9092')
topic = 'spark_cs'

# with open('./IUC-businesses.csv', mode='r') as infile:
#     reader = csv.reader(infile)
#     mydict  = {}
#     for rows in reader:
#         mydict['id'] = rows[0]
#         mydict['name'] = rows[1]
#         mydict['longitude'] = rows[2]
#         mydict['latitude'] = rows[3]
#         producer.send(topic, b'{0}'.format(mydict))
#         time.sleep(2)

with open('./user_ind_IL.csv', mode='r') as infile:
    reader = csv.reader(infile)
    mydict  = {}
    for rows in reader:
        mydict['user_ind'] = rows[0]
        # mydict['name'] = rows[1]
        # mydict['longitude'] = rows[2]
        # mydict['latitude'] = rows[3]
        producer.send(topic, b'{0}'.format(mydict))
        time.sleep(2)