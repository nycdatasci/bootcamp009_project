# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class BaseballItem(scrapy.Item):
    # define the fields for your item here like:  
	name = scrapy.Field()
	year = scrapy.Field()
	# age = scrapy.Field()
	team = scrapy.Field()
	position = scrapy.Field()
	games = scrapy.Field()
	pa = scrapy.Field()
	ab = scrapy.Field()
	runs = scrapy.Field()
	hits = scrapy.Field()
	hr = scrapy.Field()
	rbi = scrapy.Field()
	sb = scrapy.Field()
	cs = scrapy.Field()
	bb = scrapy.Field()
	so = scrapy.Field()
	ba = scrapy.Field()
	obp = scrapy.Field()
	slg = scrapy.Field()
	ops = scrapy.Field()
	ops_plus = scrapy.Field()
	tb = scrapy.Field()
	ibb = scrapy.Field()
