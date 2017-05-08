# from scrapy import Spider
# from scrapy.selector import Selector
# from demo.items import DemoItem

import scrapy
from scrapy.crawler import CrawlerProcess
from scrapy import Spider, Request
from scrapy.selector import Selector
import csv


# class DemoSpider(Spider):
# 	name = 'demo_spider'
# 	allowed_urls = ['en.wikipedia.org']
# 	start_urls = ['https://en.wikipedia.org/wiki/List_of_Academy_Award-winning_films']

class NflSpider(Spider):
	name = 'nfl_spider'
	allowed_urls = ['www.footballlocks.com']
	start_urls = ['http://www.footballlocks.com/nfl_odds_week_1.shtml']
# 			
# 	def verify(self, content):
# 		if isinstance(content, list):
# 			 if len(content) > 0:
# 				 content = content[0]
# 				 # convert unicode to str
# 				 return content.encode('ascii','ignore')
# 			 else:
# 				 return ""
# 		else:
# 			# convert unicode to str
# 			return content.encode('ascii','ignore')


	def parse(self, response):
		for i in range (1,16):
			next_url = 'http://www.footballlocks.com/nfl_odds_week_{}.shtml'.format(i)
			yield Request(next_url, callback = self.parsePage, meta = {'weeknumber': i})
	
	def parsePage(self, response):	
		tables = response.xpath("//table[@cols='6']")
		patterns = ['./tr/td[1]/text()', './tr/td[2]/text()', './tr/td[3]/text()', './tr/td[4]/text()','./tr/td[5]/text()','./tr/td[6]/text()']
		Y = 2016
		for i in range(0,len(tables),2):
			data = []
			inter = []
			for pattern in patterns:
				c = tables[i].xpath(pattern).extract() + tables[i+1].xpath(pattern).extract()
				c = map(lambda x: x.encode('ascii','ignore'),c)
				inter.append(c)
			years = [Y for _ in range(len(c))]
			weeks = [response.meta['weeknumber'] for _ in range(len(c))]
			inter.append(years)
			inter.append(weeks)
			data.append(zip(inter[0],inter[1],inter[2],inter[3],inter[4],inter[5],inter[6],inter[7]))
			print data[0][0]
			with open('Alldata4.csv','a') as csvfile:
				writer = csv.writer(csvfile, delimiter = ' ')
#  				writer.writerow(['A','B','C','D','E','F','G','H'])
				for x in data:
					for y in x:
						writer.writerow(y)
			Y = Y -1
process = CrawlerProcess({
   	'USER_AGENT': 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)'
})

process.crawl(NflSpider)
process.start()