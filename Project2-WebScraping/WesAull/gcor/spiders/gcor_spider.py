# -*- coding: utf-8 -*-
import scrapy
from scrapy import Spider
from scrapy.selector import Selector
from gcor.items import GcorItem
from gcor.items import GcorCSVItem
from gcor.items import GcorTopItem

class GcorSpider(Spider):
	name = 'googlecorrelate'
	allowed_urls = ['https://trends.google.com/trends/']
	start_urls = ['https://www.google.com/trends/correlate']

	def parse(self, response):
		search_list=[
		'Tableau',
		]
		search_url = [('https://www.google.com/trends/correlate/search?e=' + x + '&t=weekly&p=us') for x in search_list]
		for url in search_url:
			yield scrapy.Request(url, callback=self.parse_cor)

	def parse_cor(self, response):
		search_term = response.xpath('//div[@class="left results"]/h2/strong/text()').extract()			#Scraping initial search term and noting it for later meta reference.
 		search_terms = response.xpath('//div[@class="left results"]/h2/strong/text()').extract()		#Scraping initial search term to initiate list.
 		cor = '1'																						#Assigning a full correlation for the initial search term to itself.
 		search_terms += u',' + response.xpath('//li[@class="result selected"]/span/text()').extract()	#Scraping and concating name of selected highest correlated search term.
 		cor += u',' + response.xpath('//li[@class="result selected"]/small/text()').extract()			#Scraping and concating correlation of selected highest correlated search term.
 		search_terms += u',' + response.xpath('//li[@class="result"]/a/text()').extract()				#Scraping and concating remaining correlated search terms.
 		cor += u',' + response.xpath('//li[@class="result"]/small/text()').extract()					#Scraping and concating remaining correlations for other search terms.
 		corr_search_url = [('https://www.google.com/trends/correlate/search?e=' + x  +'&t=weekly&p=us') for x in search_terms]
 		item = GcorTopItem()
 		item['search_terms'] = search_terms
 		item['cor'] = cor																				#Yielding an item containing all search terms and their correlations related to initial search term.
		for url in corr_search_url:
			yield scrapy.Request(url, callback=self.parse_cor_all, meta={'search_term':search_term})	#Adding initial search term as meta

	def parse_cor_all(self, response):
		search_term = response.meta['search_term']
		corr_series = response.xpath('/html/head/script[8]/text()').extract()							#Scraping data set of time series nested in head for jc graph generation.
		assoc_terms = response.xpath('//div[@class="left results"]/h2/strong/text()').extract()			#Scraping initial assoc. search term to initiate list.
		assoc_cor = '1'																					#Assigning a full correlation for the initial assoc. search term to itself.
		assoc_terms += u',' + response.xpath('//li[@class="result selected"]/span/text()').extract()	#Scraping and concating name of selected highest correlated search term.
		assoc_cor += u',' + response.xpath('//li[@class="result selected"]/small/text()').extract()
		assoc_terms += u',' + response.xpath('//li[@class="result selected"]/span/text()').extract()
		assoc_cor += u',' + response.xpath('//li[@class="result selected"]/small/text()').extract()
		item = GcorItem()
		item['search_term'] = search_term
		item['corr_series'] = corr_series
		item['assoc_terms'] = assoc_terms
		item['assoc_cor'] = assoc_cor

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




