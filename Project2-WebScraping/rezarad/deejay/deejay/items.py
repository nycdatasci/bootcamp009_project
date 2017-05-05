# -*- coding: utf-8 -*-
import scrapy


class DeejayItem(scrapy.Item):

        # Labels
        label  = scrapy.Field()
        country = scrapy.Field()
        last_release = scrapy.Field()
        next_release = scrapy.Field()
        article = scrapy.Field()
        available = scrapy.Field()
        vinyl  = scrapy.Field()
        label_img_url = scrapy.Field()
        label_urls = scrapy.Field()


        # Releases (per label)
        url = scrapy.Field()
        title = scrapy.Field()
        catalog_number = scrapy.Field()
        styles = scrapy.Field()
        substyle = scrapy.Field()
        media_format = scrapy.Field()
        country = scrapy.Field()
        release_date = scrapy.Field()
        features = scrapy.Field()
        availability = scrapy.Field()
        stock_status = scrapy.Field()
        price = scrapy.Field()
        alt_price_hidden = scrapy.Field()
        front_cover = scrapy.Field()
        back_cover = scrapy.Field()
        tracklist = scrapy.Field()
        track_length = scrapy.Field()
        description = scrapy.Field()
