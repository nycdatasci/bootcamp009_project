# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy
from scrapy import Item, Field

class GcorItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    search_name = Field()
    search_series = Field()
 	high_corr_name = Field()
 	high_corr_corr = Field()
 	other_series_names = Field()
 	other_series_corr = Field()  


class GcorCSVItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    file_urls = Field()
    files = Field()


