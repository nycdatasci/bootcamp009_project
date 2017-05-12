# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class CoinmarketItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    Name = scrapy.Field()
    Symbol = scrapy.Field()
    Market_cap = scrapy.Field()
    Price = scrapy.Field()
    Circulating_supply = scrapy.Field()
    Volume_24h = scrapy.Field()
    Percent_change_24h = scrapy.Field()
    Percent_change_7d = scrapy.Field()
    
    pass
