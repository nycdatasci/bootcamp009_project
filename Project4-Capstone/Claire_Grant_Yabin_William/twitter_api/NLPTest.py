#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
import urllib
import unirest

mar_Auth = '53aa50aee4b0596140340719' 

def sentimentAnalysis(text):
	response = unirest.post("https://twinword-sentiment-analysis.p.mashape.com/analyze/",
		headers={ "X-Mashape-Key": "Ip3HFhr1pVmshpdpFSywwimMdye8p1D7tvijsnYxr40IJIta6I", 
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
