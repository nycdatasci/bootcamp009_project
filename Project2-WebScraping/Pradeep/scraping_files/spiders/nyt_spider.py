import scrapy
from NewsFlows.items import NewsflowsItem
from scrapy.http import Request
import urlparse
import datetime
import socket
from scrapy.contrib.spiders import XMLFeedSpider

class NytSpider(XMLFeedSpider):
	name = "nyt"
	start_urls = ('http://rss.nytimes.com/services/xml/rss/nyt/Opinion.xml',)
	#iterator = 'iternodes'
	itertag = 'item'	
	
	def parse_node(self, response, node):
		item = NewsflowsItem()
		item['page1'] = response.url
		item['page3'] = ''
		item['category'] = 'category'
		item['title'] = self.clean_string(node.xpath('title/text()')[0].extract())
		#item['article'] = node.xpath('description/text()').extract()[0]
		item['pTimestamp'] = node.xpath('pubDate/text()')[0].extract()
		item['scrape_time'] = datetime.datetime.now()
		item['spider'] = self.name
		url = node.xpath('link/text()').extract()[0].strip()
		yield Request(str(url), callback=self.parse_link,meta={'newsitem': item})
	
	def parse_link(self, response):
		item = response.meta['newsitem']
		p_selector=response.xpath('//div[@class="entry"]//p/text()')
		item['article'] = ''.join([self.clean_string(s) for s in p_selector.extract()])
		item['page2'] = response.url
		return item
		
	def clean_string(self, s):
		return s.encode('ascii', 'ignore')