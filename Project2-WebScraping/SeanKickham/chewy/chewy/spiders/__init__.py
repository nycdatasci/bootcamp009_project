# This package will contain the spiders of your Scrapy project
#
# Please refer to the documentation for information on how to create and manage
# your spiders.
# from scrapy.log import ScrapyFileLogObserver
# from scrapy import log

# class MySpider(BaseSpider):
#     name = "myspider"  

#     def __init__(self, name=None, **kwargs):
#         ScrapyFileLogObserver(open("spider.log", 'w'), level=logging.INFO).start()
#         ScrapyFileLogObserver(open("spider_error.log", 'w'), level=logging.ERROR).start()

#         super(MySpider, self).__init__(name, **kwargs)

import logging
import scrapy


class MySpider(scrapy.Spider):
    # ...
    def __init__(self, *args, **kwargs):
        logger = logging.getLogger('scrapy.spidermiddlewares.httperror')
        logger.setLevel(logging.WARNING)
        super().__init__(*args, **kwargs)