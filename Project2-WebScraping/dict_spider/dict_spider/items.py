# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

from scrapy import Item, Field


class DictSpiderItem(Item):
	date = Field()
	winner = Field()
	retailer = Field()
	retailer_location = Field()
	game = Field()
	prize = Field()
