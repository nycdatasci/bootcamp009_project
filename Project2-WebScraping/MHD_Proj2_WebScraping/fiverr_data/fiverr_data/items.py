# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy

class FiverrDataItem(scrapy.Item):
    
    category = scrapy.Field()
    subcategory = scrapy.Field()
    url = scrapy.Field()
    title = scrapy.Field()
    seller = scrapy.Field()
    rating = scrapy.Field()
    num_reviews = scrapy.Field()
    location = scrapy.Field()
    language = scrapy.Field()
    pos_rating = scrapy.Field()
    ave_reponse_time = scrapy.Field()
    starting_price = scrapy.Field()
