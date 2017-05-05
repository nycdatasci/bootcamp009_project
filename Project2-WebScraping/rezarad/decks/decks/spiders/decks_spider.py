## USE SELENIUM FOR DECKS! page numbers need to be clicked through.

# from decks_spider.items import DecksItem
# import scrapy
#
# class decks_spider(scrapy.Spider):
#     name = 'decks'
#     allowed_urls = ['https://www.decks.de/']
#     start_urls = ['https://www.decks.de/decks-sess/workfloor/start.php']
#
# def parse(self, response):
#     page_num = range(1,291)
#     table_urls  = ['https://www.decks.de/content.php/?param=/m_All/sm_Labels/page_{0}'.format(url,page) for page in page_num]
#
#     for url in table_urls
#         yield scrapy.Request(url, callback=self.parse_labels)
#
# def parse_releases_techno(self, response):
    
