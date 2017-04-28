# -*- coding: utf-8 -*-
from scrapy import Spider
from scrapy.selector import Selector
from gcor.items import GcorItem


class GcorSpider(Spider):
	name = 'googlecorrelate'
	allowed_urls = ['https://trends.google.com/trends/']
	start_urls = ['https://www.google.com/trends/correlate']
	def parse(self, response):
			yield GcorItem(
				file_urls=[
					'https://si.wsj.net/public/resources/images/OG-AN279_gdphp__E_20170428084514.png',
				]
				)


				# 'https://www.google.com/trends/correlate/csv?e=Tableau&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Python&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Cognex&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Paycom&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Logmein&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Medidata&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Cognex&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Veeva&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Inogen&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=MKSI&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Cavium&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Lendingtree&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Idexx&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Orasure&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Tmobile&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=T-mobile&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Teradyne&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Repligen&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Hologic&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Essent&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Blackbaud&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Coresite&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Evercore&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Lumentum&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Innoviva&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Nanometrics&t=weekly&p=us',
				# 'https://www.google.com/trends/correlate/csv?e=Zeltiq&t=weekly&p=us',