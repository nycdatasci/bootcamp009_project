# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class RedeyeItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    artist = scrapy.Field()
    release = scrapy.Field()
    tracks = scrapy.Field()
    label  = scrapy.Field()
    front_cover = scrapy.Field()
    catalog_num = scrapy.Field()
    price = scrapy.Field()
    available = scrapy.Field()
