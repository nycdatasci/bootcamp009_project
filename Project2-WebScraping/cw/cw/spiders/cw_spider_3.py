
import scrapy 
from scrapy.spiders import Spider

from scrapy.http import FormRequest
import scrapy
from loginform import fill_login_form
from cw.items import CWItem
import re
import datetime
import numpy as np


class Cw3Spider(Spider):
    name = "cw_spider_3"
    allowed_urls  = ['https://www.xwordinfo.com/Account/Login.aspx']
    start_urls = ['https://www.xwordinfo.com/Account/Login.aspx']

    
    def parse(self, response):

        #log in to rachel's xword
        with open('login.txt') as f:
            cred = f.readlines()
            username = cred[0].strip()
            password = cred[1].strip()


        yield scrapy.FormRequest.from_response(
            response,
            formdata={'username': username, 'password': password},
            callback=self.after_login
        )

    def after_login(self, response):
        
        today = datetime.date(2016, 3, 31)
        global begin
        begin = datetime.date(2015, 12, 1)
        delta = today - begin
        date_generator = (begin + datetime.timedelta(days=x) for x in range(0, delta.days))
        links = ['https://www.xwordinfo.com/Crossword?date=' + date.strftime('%-m/%-d/%Y') for date in date_generator]


        
        for link in links:
            yield scrapy.Request(link, meta={'dont_redirect': True,'handle_httpstatus_list': [302]}, callback=self.parse_xword)


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

        unique_words = []
        unique_words += across.xpath('.//span[@class="unique"]/text()').extract()
        unique_words += down.xpath('.//span[@class="unique"]/text()').extract()

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

            if answer in unique_words:
                item['unique'] = 'True'
            else:
                item['unique'] = 'False'

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

            if answer in unique_words:
                item['unique'] = 'True'
            else:
                item['unique'] = 'False'

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
