from scrapy import Spider, Request
from madMoney.items import Stock, Problem
import pandas as pd




class StreetSpider(Spider):
    name = "currentPrice"



    start_urls = ["https://madmoney.thestreet.com/screener/index.cfm"]

    links = pd.read_csv('links.csv')['links']

    @staticmethod
    def getAndEncode(element, path):
        """ func to find and encode for single elements and a given xpath """
        return element.xpath(path).extract_first().encode('ascii','ignore')


    def parse(self, response):
        """ parses the page from response object"""

        stock = Stock()

        stock['price'] = getAndClean(response, '//div[@id="currentPrice"]/@data-current-price')
        stock['reco'] = r.xpath('//span/sub/text()').extract_first().encode('ascii','ignore').strip()
        rows = response.xpath('//table[@class="quote__data-table"]//tbody/tr')
        keys = [getAndClean(row,'.//td[@class="quote__data-label"]/text()').lower() for row in rows]
        values = [getAndClean(row,'.//td[@class="quote__data-value"]/text()') for row in rows]
        keys = [re.sub(" |/|&|\d", "", x) for x in keys]
        values = [re.sub(" +|/\n","-",x) for x in values]


        yield stock

        for link in links:
            yield Request(url=baseStockUrl,
                          callback=self.parse, errback=self.parseFail)


        # for date in dates:
        #     # gets stock recommendations
        #     baseStockUrl = "https://madmoney.thestreet.com/screener/index.cfm?showview=stocks&showrows=500&symbol=&airdate={}&called=%25&industry=%25&sector=%25&segment=%25&pricelow=0&pricehigh=1000&sortby=airdate".format(date)
        #
        #     yield Request(url=baseStockUrl,
        #                   callback=self.parseStock, meta={'date': date}, errback=self.parseFail)

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
