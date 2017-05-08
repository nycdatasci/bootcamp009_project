# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class SteamAllItem(scrapy.Item):
    title = scrapy.Field()
    desc = scrapy.Field()
    user_rating = scrapy.Field()
    no_user = scrapy.Field()
    Rdate = scrapy.Field()
    keywords = scrapy.Field()
    game_spcs = scrapy.Field()
    critics_review = scrapy.Field()
    no_links = scrapy.Field()
    app_id = scrapy.Field()
    url = scrapy.Field()
    main_link = scrapy.Field()
    mother_node = scrapy.Field()
    type = scrapy.Field()
    list_title = scrapy.Field()
    genre = scrapy.Field()
    publish = scrapy.Field()