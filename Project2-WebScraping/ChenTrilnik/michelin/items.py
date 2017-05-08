# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class MichelinItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    Retaurant_name = scrapy.Field()
    Address = scrapy.Field()
    Cuisine = scrapy.Field()
    Price = scrapy.Field()
    Michelin_star = scrapy.Field()
    Michelin_star_review = scrapy.Field()
    Standard = scrapy.Field()
    Review = scrapy.Field()
    location = scrapy.Field()

    
