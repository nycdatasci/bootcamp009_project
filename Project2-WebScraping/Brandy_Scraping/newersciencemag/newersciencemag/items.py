# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class NewersciencemagItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    doi = scrapy.Field()
    article_type = scrapy.Field()
    title = scrapy.Field()
    volume_issue = scrapy.Field()
    date = scrapy.Field()
    related_jobs = scrapy.Field()
    first_author = scrapy.Field()
    all_authors = scrapy.Field()
    first_author_affiliation = scrapy.Field()
    affiliations = scrapy.Field()
    received = scrapy.Field()
    accepted = scrapy.Field()
    first_month_ab = scrapy.Field()
    first_month_full = scrapy.Field()
    first_month_pdf = scrapy.Field()
    second_month_ab = scrapy.Field()
    second_month_full = scrapy.Field()
    second_month_pdf = scrapy.Field()
    third_month_ab = scrapy.Field()
    third_month_full = scrapy.Field()
    third_month_pdf = scrapy.Field()
    about_text = scrapy.Field()
    #imageURL = scrapy.Field()

