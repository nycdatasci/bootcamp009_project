#Version 5
# -*- coding: utf-8 -*-
import scrapy
from slickdeals.items import SlickdealsItem
from scrapy.contrib.spiders import Rule
from scrapy.http import Request, FormRequest
from loginform import fill_login_form
from scrapy.linkextractors import LinkExtractor


class SdealSpider(scrapy.Spider):
	name = "sdeal"
	# allowed_domains = ["slickdeals.net"]
	login_page = "http://slickdeals.net/login.php"
	start_urls = ["https://slickdeals.net/forums/forumdisplay.php?f=9&daysprune=365&order=desc&sort=lastpost"]
	rules = [Rule (LinkExtractor(allow=("forumdisplay.php?f=9*&daysprune=365&order=desc&sort=lastpost")))]
	
	
	
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
			
			
	#### Login Functions ####
	login_user = 'anovavona'
	login_password = 'Oathkeeper'
	
	def start_requests(self):
		# let's start by sending a first request to login page
		yield scrapy.Request(self.login_page, self.parse_login)

	def parse_login(self, response):
		# got the login page, let's fill the login form...
		data, url, method = fill_login_form(response.url, response.body,
											self.login_user, self.login_password)

		# ... and send a request with our login data
		return FormRequest(url, formdata=dict(data),
						   method=method, callback=self.start_crawl)
	
	def start_crawl(self, response):
        # OK, we're in, let's start crawling the protected pages
		for url in self.start_urls:
			yield scrapy.Request(url)

			
			
	#### Main Parse Function ####		
			
	def parse(self, response):

		url_ids = response.xpath('//td[@class="alt1"]//div[@class="threadtitleline"]/a/@href').extract()
		url_prefix = 'https://slickdeals.net'
		
		for url_id in url_ids:
			deal_url = url_prefix + url_id
			yield scrapy.Request(deal_url, callback=self.parse_each) #Calling each URL
	
		next_page = response.xpath('//a[contains(text(), "Next")]/@href').extract_first()
		if next_page is not None:
			real_nxtpg = "https://slickdeals.net/forums/" + next_page
			yield scrapy.Request(real_nxtpg, callback=self.parse) #Call for next page
	
	
	
	#### Parsing Elements in Each Deal Page ####	
	
	def parse_each(self, response):
		#Elements from each individual page
		DealTitle = response.xpath('//div[@class="innerPadding"]//h1/text()').extract()
		DealTitle = self.verify(DealTitle) #Use the ascii converter
		DealPrice = response.xpath('//div[@id="dealPrice"]/text()').extract_first() #Can use decimal module to restrict decimal places
		DealScore = response.xpath('//span[@role="thread.score"]/text()').extract_first() #Needs to be changed to int
		OriginalURL = response.xpath('//div[@class="buy-now-action"]//a/@href').extract() #Goes to the 'See Deal' link
		ViewCount = response.xpath('//div[@id="dealViews"]/span[2]/text()').extract() #Value has commas, use int(a.replace(',' , ''))
		Comments = response.xpath('//div[@id="dealComments"]/a/label/text()').extract() #Extracts in format "X Comments", needs to be mutated
		Poster = response.xpath('//span[@class="editedDateTime"]/a/text()').extract() #Poster as in who puts up the thread/deal
		Time = response.xpath('//span[@class="editedDateTime"]//span[@class="time"]/text()').extract() #Seems to be based on Central Time Zone
		Date = response.xpath('//span[@class="editedDateTime"]//span[@class="date"]/text()').extract() #Will return 'Today' so make sure to convert
		Category = response.xpath('//span[@id="category"]/span/a/text()').extract() #Primary Categories, may be others. Sort of like user-made tags
		Image= response.xpath('//img[@id="mainImage"]').extract() #Checking if there is a product image
		Rep= response.xpath('//div[@class="statisticColumn"]//span[@class="number reputation_value"]/text()').extract() #Reputation Points from others
		DealsPosted = response.xpath('//div[@class="statisticColumn"]//span[@class="number"]/text()').extract_first() #Deals Posted

		item = SlickdealsItem()
		item['DealTitle'] = DealTitle
		item['DealPrice'] = DealPrice
		item['DealScore'] = DealScore
		item['OriginalURL'] = OriginalURL
		item['ViewCount'] = ViewCount
		item['Comments'] = Comments
		item['Poster'] = Poster
		item['Time'] = Time
		item['Date'] = Date
		item['Category'] = Category
		item['Image'] = Image
		item['Rep'] = Rep
		item['DealsPosted'] = DealsPosted
		yield item
		
		

#>>>>>>>>>>>>>> Looks good! -Thomas	
