from scrapy import Spider
from strk.items import rank2Item

class CountrySpider(Spider):

	name = "country_spider"
	allowed_urls = ['http://www.startupranking.com/']
	start_urls = ['http://www.startupranking.com/countries']


	def parse(self, response):
		rows=response.xpath('*//table[@class="table-striped wide"]/tbody/tr')




		# for i in range(1, len(rows), 2):
		for row in rows:

			country = row.xpath('./td[2]/a/text()').extract()

			number = row.xpath('./td[3]/text()').extract()


			# RDate = rows[i].xpath('./td[2]/a/text()').extract_first().encode('ascii','ignore')

			# Title = rows[i].xpath('./td[3]/b/a/text()').extract_first().encode('ascii','ignore')       	

			# PBudget = rows[i].xpath('./td[4]/text()').extract_first().encode('ascii','ignore')

			# DomesticG = rows[i].xpath('./td[5]/text()').extract_first().encode('ascii','ignore')

			# WorldwideG = rows[i].xpath('./td[6]/text()').extract_first().encode('ascii','ignore')

			item = rank2Item()
			item['country'] = country
			item['number'] = number
			yield item