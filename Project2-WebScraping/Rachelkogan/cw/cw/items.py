# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class CWItem(scrapy.Item):
    clue = scrapy.Field()
    answer = scrapy.Field()
    title = scrapy.Field()
    year = scrapy.Field()
    day = scrapy.Field()
    date = scrapy.Field()
    unique = scrapy.Field()


class UDItem(scrapy.Item):
    date = scrapy.Field()
    phrase = scrapy.Field()
    up_votes = scrapy.Field()
    down_votes = scrapy.Field()
    meaning = scrapy.Field()
    submit_date = scrapy.Field()


class OEDItem(scrapy.Item):
    word = scrapy.Field()
    entry_type = scrapy.Field()
    part_of_speech = scrapy.Field()
    month = scrapy.Field()
    year = scrapy.Field()
    
