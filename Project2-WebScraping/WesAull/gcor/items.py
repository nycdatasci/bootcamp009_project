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
	assoc_search = Field()
	search_term = Field()
	hist_search_activity = Field()
	corr_terms = Field()
	corr_terms_cor = Field()

class GcorCSVItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    file_urls = Field()
    files = Field()


