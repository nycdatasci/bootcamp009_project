	# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class rankItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
	rankwd = scrapy.Field()
	rankbyctr = scrapy.Field()
	company = scrapy.Field()
	des= scrapy.Field()
	SR_score = scrapy.Field()
	SR_web = scrapy.Field()
	SR_social = scrapy.Field()
	category = scrapy.Field()
	name = scrapy.Field()
	country = scrapy.Field()
	tag = scrapy.Field()
	SR = scrapy.Field()
	facebook = scrapy.Field()
	twitter= scrapy.Field()
	moz= scrapy.Field()
	alexa= scrapy.Field()	
	founded= scrapy.Field()
	city_state= scrapy.Field()


class rank1Item(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
	rankwd = scrapy.Field()
	country = scrapy.Field()
	company = scrapy.Field()
	des= scrapy.Field()
	SR_score = scrapy.Field()
	rankbyctr = scrapy.Field()



class rank2Item(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
	number = scrapy.Field()
	country = scrapy.Field()

class rank1Item(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
	rankwd = scrapy.Field()
	country = scrapy.Field()
	company = scrapy.Field()
	des= scrapy.Field()
	SR_score = scrapy.Field()
	rankbyctr = scrapy.Field()

class u2016Item(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
	rank = scrapy.Field()
	company = scrapy.Field()
	valuation = scrapy.Field()
	sector= scrapy.Field()
	headquarter= scrapy.Field()
	founded= scrapy.Field()
	ceo= scrapy.Field()