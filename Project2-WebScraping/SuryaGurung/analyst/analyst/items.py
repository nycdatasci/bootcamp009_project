# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

from scrapy import Item, Field


class AnalystItem(Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    # pass # do nothing
    
    ratingDate = Field()
    company = Field()
    ticker = Field()
    brokerageFirm = Field()
    rating = Field()
    ratingClass = Field()
    #target = Field()
    
    
