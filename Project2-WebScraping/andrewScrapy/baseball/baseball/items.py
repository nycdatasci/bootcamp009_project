# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class HittersItem(scrapy.Item): 
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


class PitchersItem(scrapy.Item):
	name = scrapy.Field()
	position = scrapy.Field()
	year = scrapy.Field()
	team = scrapy.Field()
	wins = scrapy.Field()
	losses = scrapy.Field()
	era = scrapy.Field()
	games = scrapy.Field()
	cg = scrapy.Field()
	sho = scrapy.Field()
	saves = scrapy.Field()
	ip = scrapy.Field()
	h = scrapy.Field()
	r = scrapy.Field()
	er = scrapy.Field()
	hr = scrapy.Field()
	bb = scrapy.Field()
	ibb = scrapy.Field()
	k = scrapy.Field()
	hbp = scrapy.Field()
	bk = scrapy.Field()
	wp = scrapy.Field()
	bf = scrapy.Field()
	era_plus = scrapy.Field()
	fip = scrapy.Field()
	whip = scrapy.Field()
	h9 = scrapy.Field()
	hr9 = scrapy.Field()
	bb9 = scrapy.Field()
	k9 = scrapy.Field()
