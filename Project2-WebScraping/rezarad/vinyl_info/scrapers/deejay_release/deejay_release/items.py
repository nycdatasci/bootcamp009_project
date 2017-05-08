# -*- coding: utf-8 -*-
import scrapy


class DeejayReleaseItem(scrapy.Item):
    # Releases (per label)
    release = scrapy.Field()
    artist = scrapy.Field()
    catalog_num = scrapy.Field()
    label = scrapy.Field()
    release_date = scrapy.Field()
    price = scrapy.Field()
    available = scrapy.Field()
