# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class YahooFinanceItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    #ticker =scrapy.Field()
    #date = scrapy.Field()
    #spot = scrapy.Field()
    optiontype = scrapy.Field()    
    strike = scrapy.Field()
    contractname = scrapy.Field()
    lastprice = scrapy.Field()
    bid = scrapy.Field()
    ask = scrapy.Field()
    change = scrapy.Field()
    changeperc = scrapy.Field()
    volumn = scrapy.Field()
    openinterest = scrapy.Field()
    impliedvolatility = scrapy.Field()
