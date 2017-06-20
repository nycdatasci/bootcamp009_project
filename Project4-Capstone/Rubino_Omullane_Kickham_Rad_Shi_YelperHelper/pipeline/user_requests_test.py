from kafka import KafkaProducer
import csv
import json
import time
from datetime import datetime

# Connect to Kafka
producer = KafkaProducer(bootstrap_servers='ec2-54-173-251-232.compute-1.amazonaws.com:9092',
                                                value_serializer=lambda v: json.dumps(v).encode('utf-8'))
topic = 'sparktest'

with open('../data/IUC-businesses.csv', mode='r') as infile:
    reader = csv.reader(infile)
    mydict  = {}
    for rows in reader:
        mydict['id'] = rows[0]
        mydict['name'] = rows[1]
        mydict['longitude'] = rows[2]
        mydict['latitude'] = rows[3]
        producer.send(topic, mydict)
        print "Sent {0}".format(mydict)
        time.sleep(2)
