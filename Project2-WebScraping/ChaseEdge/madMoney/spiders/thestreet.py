from scrapy import Spider, Request
from madMoney.items import Pick, Problem
import pandas as pd




class StreetSpider(Spider):
    name = "streetSpider"

    start_urls = ["https://madmoney.thestreet.com/screener/index.cfm?showview=stocks&showrows=500"]



    @staticmethod
    def getAndEncode(element, path):
        """ func to find and encode for single elements and a given xpath """
        return element.xpath(path).extract_first().encode('ascii','ignore')


    def parse(self, response):
        """ parses the page from response object"""

        # list of dates to loop through
        dates = response.xpath('//select[@id="airdate"]/option/@value').extract()

        # > 4 because the fist few elements are days and not dates
        dates = x = [x.encode('ascii','ignore') for x in dates if len(x) > 4]

        for date in dates:
            # gets stock recommendations
            baseStockUrl = "https://madmoney.thestreet.com/screener/index.cfm?showview=stocks&showrows=500&symbol=&airdate={}&called=%25&industry=%25&sector=%25&segment=%25&pricelow=0&pricehigh=1000&sortby=airdate".format(date)

            yield Request(url=baseStockUrl,
                          callback=self.parseStock, meta={'date': date}, errback=self.parseFail)

            #
            # yield Request(url=baseProfileUrl,
            #               callback=self.parseProfile, meta={'ticker': ticker}, errback=self.parseFail)



    def parseStock(self, response):
        """ func to parse stock recommendation pages"""

        rows = response.xpath('//table[@id="stockTable"]//tr')

        for row in rows:
            pick = Pick()
            tds = row.xpath('.//td')

            # some pages have a footer or a hearer row with a single element
            if len(tds) > 2:
                # name comes in with a () around the link
                name = tds[0].xpath('./text()').extract_first()
                name = name.split(" ")
                if len(name) > 1:
                    pick['company'] = name[0].encode('ascii','ignore')
                else:
                    pick['company'] = name[0]

                pick['ticker'] = self.getAndEncode(tds[0],'.//a/text()')
                pick['date'] = self.getAndEncode(tds[1],'.//text()')
                pick['segment'] = self.getAndEncode(tds[2], './/@alt')
                pick['call'] = self.getAndEncode(tds[3], './/@alt')
                pick['price'] = self.getAndEncode(tds[4], './/text()')
                pick['link'] = self.getAndEncode(tds[0], './/a/@href')
                pick['fulldate'] = response.meta['date']

                yield pick

            # get profile next of the company
            # baseProfileUrl = "https://marketdata.thestreet.com/stocks/company-info?symbol={}".format(response.meta['ticker'])
            #
            # yield Request(url=baseProfileUrl,
            #               callback=self.parseProfile, meta={'ticker': ticker}, errback=self.parseFail)


    def parseProfile(self, response):
        """ func to parse profile pages """
        profile = Profile()

        rows = response.xpath('//div[@class="idc-subcontainer1"]/table/tbody/tr')
        for row in rows:
            # key needs to be lower case to match Item
            k = self.getAndEncode(row, './/th/text()').lower()
            v = self.getAndEncode(row, './/td/text()')
            profile[k] = v

        # profile['ticker'] = response.meta['ticker']
        yield profile


    def parseFail(self, response):
        """ yield an empty row for the csv """
        print "tried getting " + self.ticker
        problem = Problem()
        problem['url'] = response.url
        problem['text'] = response.text
        problem['status'] = response.status

        yield problem
