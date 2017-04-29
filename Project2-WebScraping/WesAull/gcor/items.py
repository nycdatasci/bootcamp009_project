# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy
from scrapy import Item, Field

class GcorTopItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    search_terms = Field()
    cor = Field()

class GcorItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    search_term = Field()
    corr_series = Field()
    assoc_terms = Field() 
    assoc_cor = Field()

class GcorCSVItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    file_urls = Field()
    files = Field()


