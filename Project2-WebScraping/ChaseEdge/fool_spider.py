from scrapy import Spider, Request
from madMoney.items import Pick
import re


class FoolSpider(Spider):
    name = "fool_spider"

    allowed_urls = "http://caps.fool.com"
    start_urls = ['http://caps.fool.com/Ajax/GetStockPicks.aspx?objid=divScorecardView&pagenum=0&filter=0&sortcol=22&sortdir=1&playertype=4&t=01040000000000000024&pageSize=99&pgid=0&ref=http%3A//caps.fool.com/player/trackjimcramer.aspx']


    @staticmethod
    def verify(content):
        """verify that the content is there"""

        # see if the content is a list and then extract the first data
        if isinstance(content, list):
            if len(content) > 0:
                content = content[0]
                # convert to unicode to str
                x = content.encode('ascii', 'ignore').strip()
                x = re.sub('\n','', x)
                x = re.sub('\t', '', x)
                return x
            else:
                return ''
        else:
            # convert unicode to str
            return content.encode('ascii', 'ignore').strip()

    def parse(self, response):
        numPicks = response.xpath('//a[@id="stockPicks_lnkAjaxShowAll"]/text()').extract_first().encode('ascii','ignore')
        numPicks = re.findall('(\d+)', numPicks)[0]
        numPicks = int(numPicks)

        # number of total picks / by number per page
        for i in range(0, numPicks/98):
            next_url = 'http://caps.fool.com/Ajax/GetStockPicks.aspx?objid=divScorecardView&pagenum={}&filter=0&sortcol=22&sortdir=1&playertype=4&t=01040000000000000024&pageSize=99&pgid=0&ref=http%3A//caps.fool.com/player/trackjimcramer.aspx'.format(
                i)
            yield Request(next_url, callback=self.parse_page)


    def parse_page(self, response):

        # path may contain font tag
        def checkPath(path):
            r = row.xpath(path).extract()
            if len(r) == 0:
                x = re.sub(']/', ']/font/', path)
                return row.xpath(x).extract()

            return r


        rows = response.xpath('//tr')
        for row in rows:
            startDate = row.xpath('./td[1]//text()')
            ticker = row.xpath('./td[2]//text()')
            capsRating = row.xpath('./td[3]/img/@src')
            reco = row.xpath('./td[4]/img/@title')
            timeFrame = row.xpath('./td[5]//text()')
            startPrice = row.xpath('./td[6]//text()')
            stockGain = row.xpath('./td[8]//text()')
            indexGain = row.xpath('./td[9]//text()')
            score = row.xpath('./td[10]//text()')
            endDate = row.xpath('./td[11]//text()')

            capsRating = capsRating.split("_")[1].split(".")[0]

            # startDate = checkPath('./td[1]/span/text()')
            # ticker = checkPath('./td[2]/span/a/text()')
            # capsRating = checkPath('./td[3]/img/@src')
            # reco = checkPath('./td[4]/img/@title')
            # timeFrame = checkPath('./td[5]/text()')
            # startPrice = checkPath('./td[6]/text()')
            # stockGain = checkPath('./td[8]/text()')
            # indexGain = checkPath('./td[9]/text()')
            # score = checkPath('./td[10]/text()')
            # endDate = checkPath('./td[11]/text()')

            startDate = self.verify(startDate)
            ticker = self.verify(ticker)
            reco = self.verify(reco)
            capsRating = self.verify(capsRating)
            timeFrame = self.verify(timeFrame).strip()
            startPrice = self.verify(startPrice)
            stockGain = self.verify(stockGain)
            indexGain = self.verify(indexGain)
            score = self.verify(score)
            endDate = self.verify(endDate).strip()

            item = Pick()

            item['ticker'] = ticker
            item['startDate'] = startDate
            item['reco'] = reco
            item['timeFrame'] = timeFrame
            item['startPrice'] = startPrice
            item['stockGain'] = stockGain
            item['indexGain'] = indexGain
            item['score'] = score
            item['endDate'] = endDate

            print "yield this"
            yield item
