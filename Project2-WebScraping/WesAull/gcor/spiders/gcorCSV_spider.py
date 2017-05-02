from scrapy import Spider
from scrapy.selector import Selector
from gcor.items import GcorCSVItem


class GcorSpider(Spider):
	name = 'googlecorrelateCSV'
	allowed_urls = ['https://trends.google.com/trends/']
	start_urls = ['https://www.google.com/trends/correlate']
	def parse(self, response):
		yield GcorCSVItem(
			file_urls=[
 			'',
 			]
 			)