from scrapy.spiders import Spider
from cw.items import UDItem
import re
import datetime

class UDSpider(Spider):
    name = "ud_spider"
    allowed_urls  = ['http://www.urbandictionary.com/?page=']
    start_urls = ['http://www.urbandictionary.com/?page=' + str(i) for i in range(1, 615)]

    def parse(self, response):
        result = response.xpath('//div[@class="def-panel"]')

        words = result.xpath('.//a[@class="word"]/text()').extract()
        days = result.xpath('.//div[@class="ribbon"]/text()').extract()
        downs = result.xpath('.//a[@class="down"]//span[@class="count"]/text()').extract()
        ups = result.xpath('.//a[@class="up"]//span[@class="count"]/text()').extract()

        submit_dates = response.xpath('//div[@class="contributor"]/text()').extract()[1::2]

        meanings = result.xpath('.//div[@class="meaning"]')


        assert len(words) == len(days)

        for i in range(len(words)):
            word = words[i]
            day = days[i]
            up = ups[i]
            down = downs[i]
            submit_date = re.sub('\n', '', submit_dates[i])

            meaning = meanings[i].extract()
            meaning = re.sub(pattern='[\n]', repl='', string=meaning)   

            meaning = ''.join(re.split(pattern = '<|>', string=meaning)[0::2])

            word = self.verify(word)
            day = self.verify(day)
            up = self.verify(up)
            down = self.verify(down)
            meaning = self.verify(meaning)
            submit_date = self.verify(submit_date)


            item = UDItem()
            item['date'] = day
            item['phrase'] = word
            item['up_votes'] = up
            item['down_votes'] = down
            item['meaning'] = meaning
            item['submit_date'] = submit_date
            yield item


    def verify(self, content):
	    if isinstance(content, list):
                if len(content) > 0:
                    content = content[0]
                    # convert unicode to str
		    return content.encode('ascii','ignore')
		else:
		    return ""
	    else:
		    # convert unicode to str
		    return content.encode('ascii','ignore')
