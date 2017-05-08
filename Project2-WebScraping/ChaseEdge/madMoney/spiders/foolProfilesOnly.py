from scrapy import Spider, Request
from madMoney.items import FoolProfile
import pandas as pd
import re


class FoolProfiles(Spider):
    name = "fool_profiles"

    baseUrl = 'http://www.motleyfoolp.idmanagedsolutions.com/stocks/companyProfile?symbol={}'

    tickers = pd.read_csv('foolTickers.csv')['ticker']
    

    start_urls = ['http://www.motleyfoolp.idmanagedsolutions.com/stocks/companyProfile?symbol=AAPL']



    @staticmethod
    def getAndClean(element, path):
        """ extracts and encodes based on given xpath and element """
        x = element.xpath(path).extract()
        return " ".join(x).encode('ascii','ignore').strip()


    def parse(self, response):
        """ parses the page from response object"""
        profile = FoolProfile()

        # company overview items
        rows = response.xpath('//div[@class="idc-modulestyle idc-companyInfo"]//tbody/tr')
        keys = [self.getAndClean(row,'.//th/text()').lower() for row in rows]
        values = [self.getAndClean(row,'.//td/text()') for row in rows]
        for k,v in zip(keys, values):
            profile[k] = v

        profile['ticker'] = response.url.split("=")[-1]
        # competitor info
        rows = response.xpath('//div[@class="idc-modulestyle idc-competitors"]//tbody/tr')
        profile['comps'] = [self.getAndClean(row,'.//th[@class="idc-th-name"]/a/@href').split("=")[1] for row in rows]

        yield profile

        for i in range(len(self.tickers)):
            t = self.tickers[i]
            nextUrl = self.baseUrl.format(t)
            yield Request(url=nextUrl, callback=self.parse, meta = {'ticker': t}, errback=self.parseFail)

    #
    # def parseProfile(self, response):
    #     """ parse profiles """
    #



    def parseFail(self, response):
        """ yield an empty row for the csv """
        print "tried getting " + response.meta['ticker']
        problem = Problem()
        problem['ticker'] = response.meta['ticker']
        problem['url'] = response.url
        problem['text'] = response.text
        problem['status'] = response.status

        yield problem
