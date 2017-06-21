#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
import urllib
import unirest

mar_Auth = 'xxx' 

def sentimentAnalysis(text):
	response = unirest.post("https://twinword-sentiment-analysis.p.mashape.com/analyze/",
		headers={ "X-Mashape-Key": "xxx", 
		"Content-Type": "application/x-www-form-urlencoded",
        "Accept": "application/json"
        },
        params={
        "text": text
        }
       )
	return response

response = sentimentAnalysis("This is the end of the world as we know it! And I feel fine!")
print "Testing the API: {}".format(response.body["ratio"])
