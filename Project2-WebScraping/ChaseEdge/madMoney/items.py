# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html
from scrapy import Field, Item

class FoolPick(Item):
    start_date = Field()
    ticker = Field()
    caps_rating = Field()
    call = Field()
    time_frame = Field()
    start_price = Field()
    today_change = Field()
    stock_gain = Field()
    index_gain = Field()
    score = Field()
    end_date = Field()
    pitch = Field()

class Pick(Item):
    # for each recommendation
    company = Field()
    link = Field()
    ticker = Field()
    date = Field()
    segment = Field()
    call = Field()
    price = Field()
    link = Field()
    fulldate = Field()

class Profile(Item):
    ticker = Field()
    sector = Field()
    ceo = Field()
    industry = Field()
    employees = Field()

class Problem(Item):
    url = Field()
    text = Field()
    status = Field()

class FoolProfile(Item):
    industry = Field()
    sector = Field()
    employees = Field()
    ceo = Field()
    address = Field()
    phone = Field()
    website = Field()
    comps = Field()
    ticker = Field()

class Stock(Item):
    prevclose = Field()
    daylowhigh = Field()
    wklowhigh = Field()
    avgvolume = Field()
    exchange = Field()
    sharesoutstanding = Field()
    marketcap = Field()
    eps = Field()
    peratio = Field()
    divyield = Field()
    reco = Field()
