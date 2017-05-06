import scrapy 
from scrapy.spiders import Spider
from cw.items import CWItem
import re
import datetime
import numpy as np
from scrapy import Request

class Cw5Spider(Spider):
    name = "cw_spider_5"
    allowed_urls  = ['https://www.xwordinfo.com/Crossword?date=']


    start_urls = ['https://www.xwordinfo.com/Crossword?date=5/1/2017']

    def parse(self, response):
        today = datetime.date.today()
        global begin
        begin = datetime.date(2014, 1, 1)
        delta = today - begin
        date_generator = (begin + datetime.timedelta(days=x) for x in range(0, delta.days))
        base = ['https://www.xwordinfo.com/Crossword?date=' + date.strftime('%-m/%-d/%Y') for date in date_generator]

        #base = ['https://www.xwordinfo.com/Crossword?date=' + datetime.date(2014, 1, 1).strftime('%-m/%-d/%Y')]
        for link in base:
            yield Request(url=link, callback=self.parse_xword,
                          cookies={
                              "ARRAffinity": "c4738d4560f98335d13031a8c4015eb93e85e7c731a8db6964ed58201bb38900",
                              "WAWebSiteSID": "47143d987728407dbb2171565f1b66b3",
                              "ASP.NET_SessionId": "c3itlxzdrfv05lsgv241nbbc",
                              "BIGipServerEL_Customer_HTTP2": "!9weCleMP9Z2k0foDa/QqeFVfB8A6Z5Xb5hr38UsGwIIsx50hffXfos7BNyKlA/Mbfk2fe+Jcatn1vQ==; PayPal=4/30/2017 1:03:46 PM; .ASPXAUTH=A2D476D974E9DCE41610486927C4FB88CA4160E8C180535D0E82F8D79D32D68E82BC34A3EDC091230DA43F5FAC932DDDA0CAE1601E670D4B50A191C09602C98DC690AB300788BE2381BF01EEAA74BB293D112E5A",
                              "_ga": "GA1.2.438129576.1491759774"})


    def parse_xword(self, response):
        
        title = response.xpath('//h1[@id="PuzTitle"]/text()').extract_first()

        pattern = re.compile("New York Times")

        if pattern.match(title) == None:
            nyt, day, date, year = response.xpath('//h3[@id="CPHContent_SubTitleH3"]/text()').extract_first().split(',')
        else:
            nyt, day, date, year = title.split(',')
            title = ' '
            
        
        across = response.xpath('//td[@id="CPHContent_tdAcrossClues"]')
        down = response.xpath('//td[@id="CPHContent_tdDownClues"]')

        across_text = across.extract_first()
        down_text = down.extract_first()

        across_answers = across.xpath('./a//text()').extract()
        down_answers = down.xpath('./a//text()').extract()

        across_clues = re.split('[0-9]+\.|: <', across_text)[1::2]
        down_clues = re.split('[0-9]+\.|: <', down_text)[1::2]

        assert len(across_answers) == len(across_clues)
        assert len(down_answers) == len(down_clues)

        for i in range(len(across_answers)):
            answer = across_answers[i].encode('ascii', 'ignore').strip()
            clue = across_clues[i].encode('ascii', 'ignore').strip()

            clue = self.verify(clue)
            answer = self.verify(answer)
            title = self.verify(title)
            year = self.verify(year)
            day = self.verify(day)
            date = self.verify(date)

            item = CWItem()
            item['answer'] = answer
            item['clue'] = clue
            item['title'] = title

            item['year']= year
            item['day'] = day
            item['date'] = date
            yield item

        for i in range(len(down_answers)):
            answer = down_answers[i].encode('ascii', 'ignore').strip()
            clue = down_clues[i].encode('ascii', 'ignore').strip()

            clue = self.verify(clue)
            answer = self.verify(answer)
            title = self.verify(title)
            year = self.verify(year)
            day = self.verify(day)
            date = self.verify(date)

            item = CWItem()
            item['answer'] = answer
            item['clue'] = clue
            item['title'] = title

            item['year']= year
            item['day'] = day
            item['date'] = date
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
