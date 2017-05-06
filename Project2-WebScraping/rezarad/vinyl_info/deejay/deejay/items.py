# -*- coding: utf-8 -*-
import scrapy


class DeejayItem(scrapy.Item):

        # Labels
        label = scrapy.Field()
        country = scrapy.Field()
        last_release = scrapy.Field()
        next_release = scrapy.Field()
        article = scrapy.Field()
        available = scrapy.Field()
        vinyl = scrapy.Field()
        label_img_url = scrapy.Field()
        label_urls = scrapy.Field()
