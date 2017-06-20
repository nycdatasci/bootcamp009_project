from kafka import KafkaProducer
import csv
import json
import time

# Connect to Kafka
producer = KafkaProducer(bootstrap_servers='ec2-54-173-251-232.compute-1.amazonaws.com:9092')
topic = 'sparktest'

with open('../data/IUC-businesses.csv', mode='r') as infile:
    print "loop 1"
    reader = csv.reader(infile)
    mydict  = {}
    for rows in reader:
        print "loop 2"
        mydict['id'] = rows[0]
        mydict['name'] = rows[1]
        mydict['longitude'] = rows[2]
        mydict['latitude'] = rows[3]
        producer.send(topic, b'{0}'.format(mydict))
        print "end of loop 2"
        time.sleep(2)

print 'finished'
