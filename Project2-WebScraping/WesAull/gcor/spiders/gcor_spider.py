# -*- coding: utf-8 -*-
import scrapy
from scrapy import Spider
from scrapy.selector import Selector
from gcor.items import GcorItem

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
		item['assoc_search'] = response.xpath('//div[@class="left results"]/h2/strong/text()').extract()[0]	#Scraping initial search term to note as the mother search that all search terms are correlated to.
		search_terms = response.xpath('//li[@class="result selected"]/span/text()').extract()				#Scraping name of selected highest correlated search term to assoc_search.
		search_terms.extend(response.xpath('//li[@class="result"]/a/text()').extract())						#Scraping and concating remaining correlated search terms to assoc_search.
		corr_search_url = [('https://www.google.com/trends/correlate/search?e=' + x  +'&t=weekly&p=us') for x in search_terms] #Creating list of correlated search terms to scrape for their search activity time series.

		##Creating first item before entering the for loop for assoc_search as the search_term itself.  Scrapy seems to want to ignore a request to return to a page that it's scraped before through scrapy.Request.

		item['search_term'] = response.xpath('//div[@class="left results"]/h2/strong/text()').extract()[0]     #Scraping search term, whcih is the assoc_search term itself.
		exec('hist_search_activity = ' + response.xpath('/html/head/script[8]/text()').extract()[0].replace(']','[').split('[')[2])	#Scraping data set of search activity time series nested in html head for javascript graph generation.
		corr_terms = response.xpath('//li[@class="result selected"]/span/text()').extract()					#Scraping name of selected highest correlated search term to search_term.
		corr_terms.extend(response.xpath('//li[@class="result"]/a/text()').extract())						#Scraping full set of correlated search terms to search_term.
		corr_terms_cor = response.xpath('//li[@class="result selected"]/small/text()').extract()            #Scraping correlation of highest correlated search term to search_term.
		corr_terms_cor.extend(response.xpath('//li[@class="result"]/small/text()').extract())               #Scraping correlations uf full set of correlated search terms to search_term.
		item['hist_search_activity'] = hist_search_activity
		item['corr_terms'] = corr_terms
		item['corr_terms_cor'] = corr_terms_cor
		yield item

		##Preparing item template to pass into the for loop for the correlated search terms.

		item = GcorItem()
		item['assoc_search'] = response.xpath('//div[@class="left results"]/h2/strong/text()').extract()	#Scraping initial search term and noting it for later meta reference.
		for url in corr_search_url:
			yield scrapy.Request(url, callback=self.parse_cor_all, meta={'item':item})						#Adding initial item with assoc_search defined as meta to parse_cor_all.

	def parse_cor_all(self, response):
		item = response.meta['item']
		item['search_term'] = response.xpath('//div[@class="left results"]/h2/strong/text()').extract()[0]     #Scraping search term, whcih is the assoc_search term itself.
		exec('hist_search_activity = ' + response.xpath('/html/head/script[8]/text()').extract()[0].replace(']','[').split('[')[2])	#Scraping data set of search activity time series nested in html head for javascript graph generation.
		corr_terms = response.xpath('//li[@class="result selected"]/span/text()').extract()					#Scraping name of selected highest correlated search term to search_term.
		corr_terms.extend(response.xpath('//li[@class="result"]/a/text()').extract())						#Scraping full set of correlated search terms to search_term.
		corr_terms_cor = response.xpath('//li[@class="result selected"]/small/text()').extract()            #Scraping correlation of highest correlated search term to search_term.
		corr_terms_cor.extend(response.xpath('//li[@class="result"]/small/text()').extract())               #Scraping correlations uf full set of correlated search terms to search_term.
		item['hist_search_activity'] = hist_search_activity
		item['corr_terms'] = corr_terms
		item['corr_terms_cor'] = corr_terms_cor
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




