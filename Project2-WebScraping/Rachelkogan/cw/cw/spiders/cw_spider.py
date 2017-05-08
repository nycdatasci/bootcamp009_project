import scrapy 
from scrapy.spiders import Spider
from cw.items import CWItem
import re
import datetime
import numpy as np

class CwSpider(Spider):
    name = "cw_spider"
    allowed_urls  = ['https://www.xwordinfo.com/Crossword?date=']

    today = datetime.date.today()
    global begin
    begin = datetime.date(2016, 12, 1)
    delta = today - begin
    
    date_generator = (begin + datetime.timedelta(days=x) for x in range(0, delta.days))
    
    base = ['https://www.xwordinfo.com/Crossword?date=' + date.strftime('%-m/%-d/%Y') for date in date_generator]

    start_urls = base


    def parse(self, response):
        
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
