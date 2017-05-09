import scrapy
from NewsFlows.items import NewsflowsItem
from scrapy.http import Request
import urlparse
import datetime
import socket
from scrapy.contrib.spiders import XMLFeedSpider

class AbcSpider(XMLFeedSpider):
	name = "abc"
	start_urls = ('http://feeds.abcnews.com/abcnews/politicsheadlines',)
	#iterator = 'iternodes'
	itertag = 'item'

	def parse_node(self, response, node):
		item = NewsflowsItem()
		item['page1'] = response.url
		# >>>>>> Are these two just placeholders? <<<<<
		item['page3'] = ''
		item['category'] = 'category'
		item['title'] = self.clean_string(node.xpath('title/text()')[0].extract())
		#item['article'] = node.xpath('description/text()').extract()[0]
		item['pTimestamp'] = node.xpath('pubDate/text()')[0].extract()
		item['scrape_time'] = datetime.datetime.now()
		# >>>>>>>> Binding a class variable with an instance variable is tricky here. <<<<<<<<<<
		item['spider'] = self.name
		url = node.xpath('link/text()').extract()[0].strip()
		yield Request(str(url), callback=self.parse_link,meta={'newsitem': item})

	def parse_link(self, response):
		item = response.meta['newsitem']
		p_selector=response.xpath('//div[@class="article-copy"]//p/text()')
		item['article'] = ''.join([self.clean_string(s) for s in p_selector.extract()])
		item['page2'] = response.url
		return item

	def clean_string(self, s):
		return s.encode('ascii', 'ignore')
