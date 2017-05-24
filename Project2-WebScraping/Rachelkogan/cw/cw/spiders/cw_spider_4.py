
import scrapy 
from scrapy.spiders import Spider

from scrapy.http import FormRequest
from loginform import fill_login_form
from cw.items import CWItem
import re
import datetime
import numpy as np

class Cw4Spider(Spider):
    name = "cw_spider_4"
    allowed_urls  = ['https://www.xwordinfo.com/Account/Login.aspx']
    start_urls = ['https://www.xwordinfo.com/Account/Login.aspx']
    
    login_user = "rachel1792"
    login_pass = "Ma17th!!"
  
    def parse(self, response):
        args, url, method = fill_login_form(response.url, response.body, self.login_user, self.login_pass)
        print args
        print url
        print method

        today = datetime.date.today()
        global begin
        begin = datetime.date(2016, 12, 1)
        delta = today - begin
        date_generator = (begin + datetime.timedelta(days=x) for x in range(0, delta.days))
        links = ['https://www.xwordinfo.com/Crossword?date=' + date.strftime('%-m/%-d/%Y') for date in date_generator]

        for link in links:
            yield FormRequest(link, method=method, formdata=args, callback=self.after_login)

    def after_login(self, response):
        title = response.xpath('//h1[@id="PuzTitle"]/text()').extract_first()
        print title
