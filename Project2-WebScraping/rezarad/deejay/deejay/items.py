# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class DeejayItem(scrapy.Item):
        # From the table of labels
        Label  = scrapy.Field()
        Country = scrapy.Field()
        # Artists = scrapy.Field()
        Last_Release = scrapy.Field()
        Next_Release = scrapy.Field()
        Article = scrapy.Field()
        Available = scrapy.Field()
        Vinyl  = scrapy.Field()

        # From each release page
        URL = scrapy.Field()
        Title = scrapy.Field()
        Catalog_Number = scrapy.Field()
        Styles = scrapy.Field()
        Substyle = scrapy.Field()
        Format = scrapy.Field()
        # Country = scrapy.Field()
        Release_Date = scrapy.Field()
        Features = scrapy.Field()
        Availability = scrapy.Field()
        Stock_Status = scrapy.Field()
        Price = scrapy.Field()
        Alt_Price_Hidden = scrapy.Field()
        Front_Cover = scrapy.Field()
        Back_Cover = scrapy.Field()
        Tracklist = scrapy.Field()
        Track_Length = scrapy.Field()
        Description = scrapy.Field()
