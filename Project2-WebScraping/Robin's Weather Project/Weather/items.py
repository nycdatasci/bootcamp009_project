# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class WeatherItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    time = scrapy.Field()
    temperature = scrapy.Field()
    windChill = scrapy.Field()
    dewPoint = scrapy.Field()
    humidity = scrapy.Field()
    pressure = scrapy.Field()
    visibility = scrapy.Field()
    windDir = scrapy.Field()
    windSpeed = scrapy.Field()
    gustSpeed = scrapy.Field()
    precipitation = scrapy.Field()
    #events = scrapy.Field()
    #conditions = scrapy.Field()
    Date = scrapy.Field()
    #Location = scrapy.Field()