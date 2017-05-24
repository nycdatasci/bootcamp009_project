import scrapy 
from scrapy.spiders import Spider
from cw.items import CWItem
import re
import datetime
import numpy as np

class Cw2Spider(Spider):
    name = "cw_spider_2"
    allowed_urls  = ['https://www.xwordinfo.com/Account/Login.aspx']
    start_urls = ['https://www.xwordinfo.com/Account/Login.aspx']

    def parse(self, response):
        return [scrapy.FormRequest.from_response(response,
                    formdata={'username': 'rachel1792', 'password': 'Ma17th!!'},
                    callback=self.after_login)]


