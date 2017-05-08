# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class SlickdealsItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    
	DealTitle = scrapy.Field()
	DealPrice = scrapy.Field()
	DealScore = scrapy.Field()
	OriginalURL = scrapy.Field()
	ViewCount = scrapy.Field()
	Comments = scrapy.Field()
	Poster = scrapy.Field()
	Time = scrapy.Field()
	Date = scrapy.Field()
	Category = scrapy.Field()
	Image= scrapy.Field()
	Rep = scrapy.Field()
	DealsPosted = scrapy.Field()

