import scrapy
from scrapy import Spider
from cw.items import OEDItem
import re


class OEDSpider(Spider):
    name = "oed_spider"
    allowed_urls = ['http://public.oed.com/']

    months = ['march', 'june', 'september', 'december']
    years = [str(x) for x in range(2013, 2016)]

    #start_urls = ['http://public.oed.com/the-oed-today/recent-updates-to-the-oed/previous%%20updates/%s-%s-update/new-words-list-%s-%s/' % (month, year, month, year) for
#                  month in months for year in years]

    start_urls = ['http://public.oed.com/the-oed-today/recent-updates-to-the-oed/previous-updates/%s-%s-update/new-words-list-%s-%s/' % (month, 
        year, month, year) for month in months for year in years]

    start_urls += ['http://public.oed.com/the-oed-today/recent-updates-to-the-oed/march-2017-update/new-words-list-march-2017/']    

    #years = [str(x) for x in range(2010, 2011)]

    #start_urls = start_urls + ['http://public.oed.com/the-oed-today/recent-updates-to-the-oed/previous-updates/%s-%s-update/' % (month, 
    #    year) for month in months for year in years]


    def parse(self, response):
        d = response.xpath('//h1/text()').extract_first()
        mon, yr = d.split(' ')[-2:]
        
        tables = response.xpath('//h3/following-sibling::ul')


        for i in range(3):
            words = tables[0].xpath('./li/text()').extract()

            for ul in words:
                ul = ul.split(',')

                item = OEDItem()
                item['word'] = self.verify(ul[0])
                item['part_of_speech'] = self.verify(ul[1])
                
                item['month'] = self.verify(mon)
                item['year'] = self.verify(yr)

                entry_type_dict = {0: 'new word entry', 1: 'new sub-entry', 2: 'new word sense'}
                item['entry_type'] = self.verify(entry_type_dict[i])
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
