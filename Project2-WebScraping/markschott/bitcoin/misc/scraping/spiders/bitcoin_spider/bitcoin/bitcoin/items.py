# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class BitcoinItem(scrapy.Item):
    #prices = scrapy.Field()
    event_no = scrapy.Field()
    title = scrapy.Field()
    val = scrapy.Field()
    val_after_10days = scrapy.Field()
    story = scrapy.Field()
    sources = scrapy.Field()    
    pass
