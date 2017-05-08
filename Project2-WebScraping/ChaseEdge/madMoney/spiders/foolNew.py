from scrapy import Spider, Request
from madMoney.items import FoolPick, FoolProfile, Problem
import pandas as pd
import re


class FoolNew(Spider):
    name = "fool_new"

    baseUrl = "http://caps.fool.com/Ajax/GetStockPicks.aspx?objid=divScorecardView&pagenum={}&filter=0&sortcol=22&sortdir=1&playertype=4&t=01040000000000000024&pageSize=99&pgid=0&ref=http%3A//caps.fool.com/player/trackjimcramer.aspx"

    # starting page number is 0
    start_urls = [baseUrl.format(0)]

    profilesChecked = []

    @staticmethod
    def getAndClean(element, path):
        """ extracts and encodes based on given xpath and element """
        x = element.xpath(path).extract()
        return " ".join(x).encode('ascii','ignore').strip()


    def parse(self, response):
        """ parses the page from response object"""

        # getting number of total stock picks
        numPicks = self.getAndClean(response, '//a[@id="stockPicks_lnkAjaxShowAll"]/text()')

        # extract just the numbers from string to know how many iterations are needed
        numPicks = re.findall('(\d+)', numPicks)[0]
        numPicks = int(numPicks)
        totalPages = numPicks/99

        # number of total picks / by number per page
        for i in range(0, totalPages):
            next_url = self.baseUrl.format(i)
            yield Request(next_url, callback=self.parsePicks, errback=self.parseFail)



    def parsePicks(self, response):
        """ parses the page with stock recommendations"""

        rows = response.xpath('//tr')

        # get labels for dictionary item
        keys = [self.getAndClean(x,'.//text()').lower() for x in rows[0].xpath('.//td')]
        keys = [re.sub(" ","_",x) for x in keys]
        keys = [re.sub("\(|\)","",x) for x in keys]

        # get values
        for i in range(1,len(rows)):
            pick = FoolPick()
            tds = rows[i].xpath('.//td')
            values = [self.getAndClean(td, ".//text() | .//img/@src | .//img/@title") for td in tds]

            for k,v in zip(keys, values):
                pick[k] = v

            yield pick

            # check to see if profile has already been checked
            if pick['ticker'] not in self.profilesChecked:
                self.profilesChecked.append(pick['ticker'])
                profileUrl = 'http://www.motleyfoolp.idmanagedsolutions.com/stocks/companyProfile?symbol={}'
                yield Request(url=profileUrl.format(pick['ticker']),
                              callback=self.parseProfile, meta={'ticker': pick['ticker']}, errback=self.parseFail)


    def parseProfile(self, response):
        """ func to parse profile pages """

        profile = FoolProfile()

        # company overview items
        rows = response.xpath('//div[@class="idc-modulestyle idc-companyInfo"]//tbody/tr')
        keys = [self.getAndClean(row,'.//th/text()').lower() for row in rows]
        values = [self.getAndClean(row,'.//td/text()') for row in rows]
        for k,v in zip(keys, values):
            profile[k] = v

        profile['ticker'] = response.meta['ticker']
        # competitor info
        rows = response.xpath('//div[@class="idc-modulestyle idc-competitors"]//tbody/tr')
        profile['comps'] = [self.getAndClean(row,'.//th[@class="idc-th-name"]/a/@href').split("=")[1] for row in rows]

        yield profile


    def parseFail(self, response):
        """ yield an empty row for the csv """
        print "tried getting " + response.meta['ticker']
        problem = Problem()
        problem['ticker'] = response.meta['ticker']
        problem['url'] = response.url
        problem['text'] = response.text
        problem['status'] = response.status

        yield problem
