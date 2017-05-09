# -*- coding: utf-8 -*-

import scrapy
from sciencemag.items import SciencemagItem

class ScienceMagSpider(scrapy.Spider):
	name = 'sciencemag_spider'
	allowed_urls = ['http://science.sciencemag.org/content']
	#start_urls = ['http://science.sciencemag.org/content/by/volume/283',
	#]

	#>>>>>>>>>>>>>>>>> I assume you didn't make these programmatically because you copied/pasted...
	start_urls = ['http://science.sciencemag.org/content/by/volume/283',
				'http://science.sciencemag.org/content/by/volume/284',
				'http://science.sciencemag.org/content/by/volume/285',
				'http://science.sciencemag.org/content/by/volume/286',
				'http://science.sciencemag.org/content/by/volume/287',
				'http://science.sciencemag.org/content/by/volume/288',
				'http://science.sciencemag.org/content/by/volume/289',
				'http://science.sciencemag.org/content/by/volume/290',
				'http://science.sciencemag.org/content/by/volume/291',
				'http://science.sciencemag.org/content/by/volume/292',
				'http://science.sciencemag.org/content/by/volume/293',
				'http://science.sciencemag.org/content/by/volume/294',
				'http://science.sciencemag.org/content/by/volume/295',
				'http://science.sciencemag.org/content/by/volume/296',
				'http://science.sciencemag.org/content/by/volume/297',
				'http://science.sciencemag.org/content/by/volume/298',
				'http://science.sciencemag.org/content/by/volume/299',
				'http://science.sciencemag.org/content/by/volume/300',
				'http://science.sciencemag.org/content/by/volume/301',
				'http://science.sciencemag.org/content/by/volume/302',
				'http://science.sciencemag.org/content/by/volume/303',
				'http://science.sciencemag.org/content/by/volume/304',
				'http://science.sciencemag.org/content/by/volume/305',
				'http://science.sciencemag.org/content/by/volume/306',
				'http://science.sciencemag.org/content/by/volume/307',
				'http://science.sciencemag.org/content/by/volume/308',
				'http://science.sciencemag.org/content/by/volume/309']
				# 'http://science.sciencemag.org/content/by/volume/310',
				# 'http://science.sciencemag.org/content/by/volume/311',
				# 'http://science.sciencemag.org/content/by/volume/312',
				# 'http://science.sciencemag.org/content/by/volume/313',
				# 'http://science.sciencemag.org/content/by/volume/314',
				# 'http://science.sciencemag.org/content/by/volume/315',
				# 'http://science.sciencemag.org/content/by/volume/316',
				# 'http://science.sciencemag.org/content/by/volume/317',
				# 'http://science.sciencemag.org/content/by/volume/318',
				# 'http://science.sciencemag.org/content/by/volume/319',
				# 'http://science.sciencemag.org/content/by/volume/320',
				# 'http://science.sciencemag.org/content/by/volume/321',
				# 'http://science.sciencemag.org/content/by/volume/322',
				# 'http://science.sciencemag.org/content/by/volume/323',
				# 'http://science.sciencemag.org/content/by/volume/324',
				# 'http://science.sciencemag.org/content/by/volume/325',
				# 'http://science.sciencemag.org/content/by/volume/326',
				# 'http://science.sciencemag.org/content/by/volume/327',
				# 'http://science.sciencemag.org/content/by/volume/328',
				# 'http://science.sciencemag.org/content/by/volume/329',
				# 'http://science.sciencemag.org/content/by/volume/330',
				# 'http://science.sciencemag.org/content/by/volume/331',
				# 'http://science.sciencemag.org/content/by/volume/332',
				# 'http://science.sciencemag.org/content/by/volume/333',
				# 'http://science.sciencemag.org/content/by/volume/334',
				# 'http://science.sciencemag.org/content/by/volume/335',
				# 'http://science.sciencemag.org/content/by/volume/336',
				# 'http://science.sciencemag.org/content/by/volume/337',
				# 'http://science.sciencemag.org/content/by/volume/338',
				# 'http://science.sciencemag.org/content/by/volume/339',
				# 'http://science.sciencemag.org/content/by/volume/340',
				# 'http://science.sciencemag.org/content/by/volume/341',
				# 'http://science.sciencemag.org/content/by/volume/342',
				# 'http://science.sciencemag.org/content/by/volume/343',
				# 'http://science.sciencemag.org/content/by/volume/344',
				# 'http://science.sciencemag.org/content/by/volume/345',
				# 'http://science.sciencemag.org/content/by/volume/346',
				# 'http://science.sciencemag.org/content/by/volume/347',
				# 'http://science.sciencemag.org/content/by/volume/348',
				# 'http://science.sciencemag.org/content/by/volume/349',
				# 'http://science.sciencemag.org/content/by/volume/350',
				# 'http://science.sciencemag.org/content/by/volume/351',
				# 'http://science.sciencemag.org/content/by/volume/352',
				# 'http://science.sciencemag.org/content/by/volume/353',
				# 'http://science.sciencemag.org/content/by/volume/354',
				# 'http://science.sciencemag.org/content/by/volume/355',
				# 'http://science.sciencemag.org/content/by/volume/356']

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

#go to each issue in the volume:

	def parse(self,response):
		links = response.xpath('//div[@class="issue-link"]/a/@href').extract()
		for link in links:
			new_url = 'http://science.sciencemag.org' + link
			# print "THESE ARE THE NEW URLS"
			# print new_url

			yield scrapy.Request(new_url, callback = self.parse_issues)

# #direct to the info tab of the cover article:

	def parse_issues(self, response):

		about_text = ' '.join(response.xpath('//div[@class="caption cover-img"]/p/text()').extract())
		about_text = response.xpath('//div[@class="caption cover-img"]/p/text()').extract()
		about_text = ' '.join(about_text)
		# print "____________________________"
		# print about_text
		# print "_____________________________"
		
		covers = response.xpath('//div[@class="caption cover-img"]/p/a/@href').extract()
		for cover in covers:
			cover_url = 'http://science.sciencemag.org' + cover + '/tab-article-info'
			# print cover_url

			yield scrapy.Request(cover_url, callback = self.parse_info, meta = {'about_text': about_text})

# # collect the items from the site to analyze:

	def parse_info(self, response):
		about_text = response.meta['about_text']
		#print about_text
		about_text = self.verify(about_text)
		doi = response.xpath('//div[@class="field field-name-field-highwire-a-doi field-type-text field-label-inline clearfix"]//a/@href').extract_first()
		#print doi
		doi = self.verify(doi)
		article_type = response.xpath('//div[@class="overline"]/text()').extract_first()
		#print article_type
		article_type = self.verify(article_type)
		title = response.xpath('//div[@class="highwire-cite-title"]/text()').extract_first()
		#print title
		title = self.verify(title)
		volume_issue = response.xpath('//p[@class="highwire-cite-metadata minor"]/text()').extract_first()
		#print volume_issue
		volume_issue = self.verify(volume_issue)
		date = response.xpath('//p[@class="highwire-cite-metadata minor"]/text()[2]').extract_first()
		#print date
		date = self.verify(date)
		related_jobs = response.xpath('//ul[@class="highwire-article-collection-term-list highwire-list"]//a/text()').extract()
		related_jobs = ', '.join(related_jobs)
		#print related_jobs
		related_jobs = self.verify(related_jobs)
		first_author = response.xpath('//div[@class="article byline byline--article"]//span[@class="name"]/text()').extract_first()
		#print first_author
		first_author = self.verify(first_author)
		all_authors = response.xpath('//div[@class="article byline byline--article"]//span[@class="name"]/text()').extract()
		all_authors = ', '.join(all_authors).strip()
		#print all_authors
		all_authors = self.verify(all_authors)
		first_author_affiliation = response.xpath('//div[@class="article byline byline--article"]//address/text()').extract_first()
		first_author_affiliation = first_author_affiliation.strip()
		#print first_author_affiliation
		first_author_affiliation = self.verify(first_author_affiliation)
		affiliations = response.xpath('//div[@class="article byline byline--article"]//address/text()').extract()
		affiliations = map(lambda s: s.strip(), affiliations)
		affiliations = ", ".join(affiliations)
		#print affiliations
		affiliations = self.verify(affiliations)
		received = response.xpath('//ul[@class="publication-history"]/li/text()').extract_first()
		received = received.replace('Received for publication  ','')
		#print received
		received = self.verify(received)
		accepted = response.xpath('//ul[@class="publication-history"]/li[2]/text()').extract_first()
		accepted = accepted.replace('Accepted for publication  ','')
		#print accepted
		accepted = self.verify(accepted)
		first_month_ab = response.xpath('//table[@class="highwire-stats"]//tr[2]/td[2]/text()').extract_first()
		#print first_month_ab
		first_month_ab = self.verify(first_month_ab)
		first_month_full = response.xpath('//table[@class="highwire-stats"]//tr[2]/td[3]/text()').extract_first()
		#print first_month_full
		first_month_full = self.verify(first_month_full)
		first_month_pdf = response.xpath('//table[@class="highwire-stats"]//tr[2]/td[4]/text()').extract_first()
		#print first_month_pdf
		first_month_pdf = self.verify(first_month_pdf)
		second_month_ab = response.xpath('//table[@class="highwire-stats"]//tr[3]/td[2]/text()').extract_first()
		#print second_month_ab
		second_month_ab = self.verify(second_month_ab)
		second_month_full = response.xpath('//table[@class="highwire-stats"]//tr[3]/td[3]/text()').extract_first()
		#print second_month_full
		second_month_full = self.verify(second_month_full)
		second_month_pdf = response.xpath('//table[@class="highwire-stats"]//tr[3]/td[4]/text()').extract_first()
		#print second_month_pdf
		second_month_pdf = self.verify(second_month_pdf)
		third_month_ab = response.xpath('//table[@class="highwire-stats"]//tr[4]/td[2]/text()').extract_first()
		#print third_month_ab
		third_month_ab = self.verify(third_month_ab)
		third_month_full = response.xpath('//table[@class="highwire-stats"]//tr[4]/td[3]/text()').extract_first()
		#print third_month_full
		third_month_full = self.verify(third_month_full)
		third_month_pdf = response.xpath('//table[@class="highwire-stats"]//tr[4]/td[4]/text()').extract_first()
		#print third_month_pdf
		third_month_pdf = self.verify(third_month_pdf)
# 		#imageURL = response.xpath('//img[@class="highlight-image"]/@src').extract_first()
# 		#imageURL = self.verify(imageURL)

# 		#for 

		item = SciencemagItem()
		item['doi'] = doi
		item['article_type'] = article_type
		item['title'] = title
		item['volume_issue'] = volume_issue
		item['date'] = date
		item['related_jobs'] = related_jobs
		item['first_author'] = first_author
		item['all_authors'] = all_authors
		item['first_author_affiliation'] = first_author_affiliation
		item['affiliations'] = affiliations
		item['received'] = received
		item['accepted'] = accepted
		item['first_month_ab'] = first_month_ab
		item['first_month_full'] = first_month_full
		item['first_month_pdf'] = first_month_pdf
		item['second_month_ab'] = second_month_ab
		item['second_month_full'] = second_month_full
		item['second_month_pdf'] = second_month_pdf
		item['third_month_ab'] = third_month_ab
		item['third_month_full'] = third_month_full
		item['about_text'] = about_text
		#item['imageURL'] = imageURL

		yield item



