# -*- coding: utf-8 -*-
import scrapy
from scrapy import Spider
from scrapy.selector import Selector
from gcor.items import GcorItem
from gcor.items import GcorCSVItem

class GcorSpider(Spider):
	name = 'googlecorrelate'
	allowed_urls = ['https://trends.google.com/trends/']
	start_urls = ['https://www.google.com/trends/correlate']

	def verify(self, content):
		if isinstance(content, list):
			if len(content) > 0:
				content = content[0]    # convert unicode to str
				return content.encode('ascii','ignore')
			else:
				return ""
		else:                           # convert unicode to str
			return content.encode('ascii','ignore')

	def parse(self, response):
		search_list=[
		'Tableau',
		]
		search_url = [('https://www.google.com/trends/correlate/search?e=' + x + '&t=weekly&p=us') for x in search_list]
		for url in search_url:
			yield scrapy.Request(url, callback=self.parse_cor)

	def parse_cor(self, response):
		item = GcorItem()
		item['search_term'] = response.xpath('//div[@class="left results"]/h2/strong/text()').extract()		#Scraping initial search term and noting it for later meta reference.
 		search_terms = response.xpath('//div[@class="left results"]/h2/strong/text()').extract()			#Scraping initial search term to initiate list.
 		cor = [u'1']																						#Assigning a full correlation for the initial search term to itself.
 		search_terms.extend(response.xpath('//li[@class="result selected"]/span/text()').extract())			#Scraping and concating name of selected highest correlated search term.
 		cor.extend(response.xpath('//li[@class="result selected"]/small/text()').extract())					#Scraping and concating correlation of selected highest correlated search term.
 		search_terms.extend(response.xpath('//li[@class="result"]/a/text()').extract())						#Scraping and concating remaining correlated search terms.
 		cor.extend(response.xpath('//li[@class="result"]/small/text()').extract())							#Scraping and concating remaining correlations for other search terms.
 		corr_search_url = [('https://www.google.com/trends/correlate/search?e=' + x  +'&t=weekly&p=us') for x in search_terms]
 		item['search_terms'] = search_terms
 		item['cor'] = cor																					#Yielding an item containing all search terms and their correlations related to initial search term.
		for url in corr_search_url:
			yield scrapy.Request(url, callback=self.parse_cor_all, meta={'item':item})						#Adding initial search term as meta

	def parse_cor_all(self, response):
		item = response.meta['item']
		item['assoc_term'] = response.xpath('//div[@class="left results"]/h2/strong/text()').extract()
		corr_series = response.xpath('/html/head/script[8]/text()').extract()[0].split('\n')[2]				#Scraping data set of time series nested in head for jc graph generation.
		assoc_terms = response.xpath('//div[@class="left results"]/h2/strong/text()').extract()				#Scraping initial assoc. search term to initiate list.
		assoc_cor = [u'1']																					#Assigning a full correlation for the initial assoc. search term to itself.
		assoc_terms.extend(response.xpath('//li[@class="result selected"]/span/text()').extract())			#Scraping and concating name of selected highest correlated search term.
		assoc_cor.extend(response.xpath('//li[@class="result selected"]/small/text()').extract())
		assoc_terms.extend(response.xpath('//li[@class="result"]/span/text()').extract())
		assoc_cor.extend(response.xpath('//li[@class="result"]/small/text()').extract())
		item['corr_series'] = corr_series
		item['assoc_terms'] = assoc_terms
		item['assoc_cor'] = assoc_cor
		yield item

				# 'Python',
				# 'Cognex',
				# 'Paycom',
				# 'Logmein',
				# 'Medidata',
				# 'Cognex',
				# 'Veeva',
				# 'Inogen',
				# 'MKSI',
				# 'Cavium',
				# 'Lendingtree',
				# 'Idexx',
				# 'Orasure',
				# 'Tmobile',
				# 'T-mobile',
				# 'Teradyne',
				# 'Repligen',
				# 'Hologic',
				# 'Essent',
				# 'Blackbaud',
				# 'Coresite',
				# 'Evercore',
				# 'Lumentum',
				# 'Innoviva',
				# 'Nanometrics',
				# 'Zeltiq',




