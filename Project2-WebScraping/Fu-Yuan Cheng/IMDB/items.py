# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class ImdbItem(scrapy.Item):
    # define the fields for your item here like:
    name = scrapy.Field()
    year = scrapy.Field()
    rate = scrapy.Field()
    length = scrapy.Field()
    date_c = scrapy.Field()
    Director = scrapy.Field()
    actors = scrapy.Field()
    genre = scrapy.Field()
    budget = scrapy.Field()
    open_week = scrapy.Field()
    gross = scrapy.Field()

