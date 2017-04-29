# -*- coding: utf-8 -*-
from scrapy import Spider
from scrapy.selector import Selector
from gcor.items import GcorItem
from gcor.items import GcorCSVItem

class GcorSpider(Spider):
	name = 'googlecorrelate'
	allowed_urls = ['https://trends.google.com/trends/']
	start_urls = ['https://www.google.com/trends/correlate']
	search_list=[
				'Tableau',
				'Python',
				'Cognex',
				'Paycom',
				'Logmein',
				'Medidata',
				'Cognex',
				'Veeva',
				'Inogen',
				'MKSI',
				'Cavium',
				'Lendingtree',
				'Idexx',
				'Orasure',
				'Tmobile',
				'T-mobile',
				'Teradyne',
				'Repligen',
				'Hologic',
				'Essent',
				'Blackbaud',
				'Coresite',
				'Evercore',
				'Lumentum',
				'Innoviva',
				'Nanometrics',
				'Zeltiq',
                ]
	search_url = ['https://www.google.com/trends/correlate/search?e=' + x for x in search_list + '&t=weekly&p=us']

	def parse(self, response):
		for url in search_url:
			yield scrapy.Request(url, callback=self.parse_cor)

    def parse_cor(self, response):
 		search_name = response.xpath('//div[@class="left results"]/h2/strong/text()').extract()
        search_series = response.xpath('/html/head/script[8]/text()').extract()
 		high_corr_name = response.xpath('//li[@class="result selected"]/span/text()').extract()
 		high_corr_corr = response.xpath('//li[@class="result selected"]/small/text()').extract()
 		other_series_names = response.xpath('//li[@class="result"]/a/text()').extract()
 		other_series_corr = response.xpath('//li[@class="result"]/small/text()').extract()

        corr_search_url = ['https://www.google.com/trends/correlate/search?e=' + x for x in corr_search_list + '&t=weekly&p=us']

        for url in corr_search_url:
            yield scrapy.Request(url, callback=self.parse_cor_other, meta={'search_name':search_name})

    def parse_cor_other(self, response):
        search_name = response.meta['search_name']
 		other_corr_name = response.xpath('//div[@class="left results"]/h2/strong/text()').extract()
        other_corr_series = response.xpath('/html/head/script[8]/text()').extract()
 		other_high_corr_name = response.xpath('//li[@class="result selected"]/span/text()').extract()
 		other_high_corr_corr = response.xpath('//li[@class="result selected"]/small/text()').extract()


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




