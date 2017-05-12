
import scrapy
from fiverr.items import FiverrItem
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import random


class FiverrSpider(scrapy.Spider):
	name = "fiverr_spider"
	allowed_urls = ["https://www.fiverr.com/"]
	start_urls = ["https://www.fiverr.com/"]

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

		links = response.xpath('//ul[@class="row flex"]/li/a/@href').extract()
		links2 = set(links)
		links3 = list(links2)
		random.shuffle(links3)

		for link in links3:
			url = "https://www.fiverr.com" + link
			time.sleep(random.randint(1,5))
			yield scrapy.Request(url, callback = self.parse_category)
			print "Waiting between categories"


	def parse_category(self, response):

		category = response.xpath('//div[@class="wrapper"]/h1/text()').extract_first()
		subcategory_links = response.xpath('//div[@class="categories-boxes-container"]//a[@class="title"]/@href').extract()

		random.shuffle(subcategory_links)

		for link in subcategory_links:
			time.sleep(random.randint(5,10))
			new_url = "https://www.fiverr.com" + link
			yield scrapy.Request(new_url, callback = self.parse_subcategory, meta = {"category":category, "url":new_url})
			print "Waiting between subcategories"	
			#time.sleep(random.randint(30,60))

	def parse_subcategory(self, response):

		category = response.meta["category"]

		subcategory = response.xpath('//div[@class="wrapper"]/h1/text()').extract_first()

		driver = webdriver.Chrome()
		driver.get(response.meta["url"])
		time.sleep(random.randint(10,15))

		for x in range(5):
			
			vendors = driver.find_elements_by_xpath('//a[@itemprop="url"]')
			
			url_list = []

			for vendor in vendors:
				url_list.append(vendor.get_attribute("href"))
			
			random.shuffle(url_list)

			for url in url_list:
				#time.sleep(random.randint(10,15))
				#yield scrapy.Request(url, callback = self.parse_vendor, meta = {"category":category, "subcategory": subcategory, 'dont_redirect': True, "handle_httpstatus_list" : [301, 302, 303, 403]})
				#print "Waiting between pages"
				item = FiverrItem()

				item["category"] = category
				item["subcategory"] = subcategory
				item["url"] = url

				yield item 

			button = driver.find_element_by_xpath('//a[@class="link-no-style js-next  js-report-to-aux-data"]')
			button.click()
			time.sleep(5)

	# def parse_vendor(self,response):

	# 	try:
	# 		category = response.meta["category"]
	# 		category = self.verify(category)

	# 		subcategory = response.meta["subcategory"]
	# 		subcategory = self.verify(subcategory)

	# 		title = response.xpath('//span[@class="gig-title"]/text()').extract_first()
	# 		title = title.strip()
	# 		title = self.verify(title)
			
	# 		seller = response.xpath('//a[@class="seller-link"]//text()').extract_first()
	# 		seller = self.verify(seller)

	# 		rating = response.xpath('//span[@class="stats-row"]/span/@class').extract_first()
	# 		rating = self.verify(rating)

	# 		num_reviews = response.xpath('//span[@class="stats-row"]/a/text()').extract_first()
	# 		num_reviews = self.verify(num_reviews)

	# 		stats = response.xpath('//ul[@class="seller-stats cf"]//text()').extract()

	# 		for i in range(len(stats)):
	# 			stats[i] = stats[i].strip()

	# 		stats_dic = {}

	# 		for x in range(0,len(stats)-1, 2):
	# 			stats_dic[stats[x]] = stats[x + 1]

	# 		location = stats_dic.get("From", "")
	# 		location = self.verify(location)

	# 		pos_rating = stats_dic.get("Positive Rating", "")
	# 		pos_rating = self.verify(pos_rating)

	# 		ave_reponse_time = stats_dic.get("Avg. Response Time", "")
	# 		ave_reponse_time = self.verify(ave_reponse_time)

	# 		try:
	# 			starting_price = response.xpath('//span[@class="left-aligned js-str-currency js-price js-package-number-1"]/text()').extract_first()
	# 			starting_price = starting_price.strip()
	# 		except:
	# 			starting_price = ""

	# 		starting_price = self.verify(starting_price)

	# 		item = FiverrItem()

	# 		item['category'] = category
	# 		item['subcategory'] = subcategory
	# 		item['title'] = title
	# 		item['seller'] = seller
	# 		item['rating'] = rating
	# 		item['num_reviews'] = num_reviews 
	# 		item['location'] = location 
	# 		item['pos_rating'] = pos_rating 
	# 		item['ave_reponse_time'] = ave_reponse_time
	# 		item['starting_price'] = starting_price  

	# 		yield item

	# 	except:
	# 		pass













