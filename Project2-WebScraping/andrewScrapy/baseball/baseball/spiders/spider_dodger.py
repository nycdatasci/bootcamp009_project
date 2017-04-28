import scrapy
import time
from baseball.items import BaseballItem


class SpiderDodger(scrapy.Spider):
	name = "spider_dodger"
	allowed_urls = ['http://www.baseball-reference.com/']
	start_urls = ['http://www.baseball-reference.com/awards/hof.shtml']


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



	def parse(self, response):
		'''
		Let's get list of links to crawl first
		'''
		links = response.xpath('//td[@class="left "]/a/@href').extract()

		for link in links:
			new_url = 'http://www.baseball-reference.com' + link
			print new_url
			time.sleep(10)
			yield scrapy.Request(new_url, callback = self.parse_player)



	def parse_player(self, response):
		'''
		scrape the player pages
		'''
		name = response.xpath('//*[@id="meta"]/div[2]/h1/text()').extract_first()
		name = self.verify(name	)	
		
		rows = response.xpath('//*[@id="content"]//table/tbody/tr')		
		for i in range(1, len(rows)):
			year = rows[i].xpath('./th/text()').extract_first()
			age = rows[i].xpath('./td[1]/text()').extract_first()
			team = rows[i].xpath('./td[2]/a/text()').extract_first()			
			
			# verify
			year = self.verify(year)
			age = self.verify(year)
			team = self.verify(team)			
			
			item = BaseballItem()
			item['name'] = name
			item['year'] = year
			item['age'] = age
			item['team'] = team			
			
			time.sleep(10)
			yield item




