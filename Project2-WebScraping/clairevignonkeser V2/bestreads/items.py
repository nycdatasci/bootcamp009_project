# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class BestreadsItem(scrapy.Item):
    # define the fields for your item here like:
    MainGenre = scrapy.Field()
    AllGenres = scrapy.Field()
    Title = scrapy.Field()
    Author = scrapy.Field()
    Score = scrapy.Field()
    NumberOfRating = scrapy.Field()
    NumberOfReviews = scrapy.Field()
    Year = scrapy.Field()
    NumberOfPages = scrapy.Field()
    BookCoverURL = scrapy.Field()
    Description = scrapy.Field()
    Reviews = scrapy.Field()
    Ranking = scrapy.Field()
    TotalScore = scrapy.Field()
