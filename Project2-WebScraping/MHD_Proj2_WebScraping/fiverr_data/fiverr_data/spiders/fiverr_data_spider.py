
import scrapy
from fiverr_data.items import FiverrDataItem
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import pandas as pd
import random


class FiverrSpider(scrapy.Spider):
	name = "fiverr_data_spider"
	allowed_urls = ["https://www.fiverr.com/"]

	fiverr = pd.read_csv("../../fiverr_urls/fiverr_urls/fiverr_urls_5pages.csv")
	#missing = pd.read_csv("./missing_urls.csv") # For Missing URLs
	url_list = list(fiverr.url)
	#url_list = list(missing.url) # For Missing URLs

	start_urls = url_list[16600:16800]
	#start_urls = url_list # For Missing URLs

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

	def parse(self,response):

		category = response.xpath('//a[@data-gtm-label="bread-crumbs-category"]/text()').extract_first()
		category = self.verify(category)

		subcategory = response.xpath('//a[@data-gtm-label="bread-crumbs-sub-category"]/text()').extract_first()
		subcategory = self.verify(subcategory)

		url = response.request.url
		url = self.verify(url)

		title = response.xpath('//span[@class="gig-title"]/text()').extract_first()
		title = title.strip()
		try:
			title = self.verify(title)
		except:
			title = ""	

		seller = response.xpath('//a[@class="seller-link"]//text()').extract_first()
		try:
			seller = self.verify(seller)
		except:
			seller = ""
		
		rating = response.xpath('//span[@class="stats-row"]/span/@class').extract_first()
		try:
			rating = self.verify(rating)
		except: 
			rating = ""
		
		num_reviews = response.xpath('//span[@class="stats-row"]/a/text()').extract_first()
		try:
			num_reviews = self.verify(num_reviews)
		except:
			num_reviews = ""

		stats_dic = {}

		stats = response.xpath('//ul[@class="seller-stats cf"]/li')

		for i in range(len(stats)):
			if stats[i].xpath('./small/text()').extract_first() != "Speaks":
				stats_dic[stats[i].xpath('./small/text()').extract_first()] = "".join(stats[i].xpath('./text()').extract()).strip()
			elif stats[i].xpath('./small/text()').extract_first() == "Speaks":
				test = stats[i].xpath('./ul//text()').extract()
				for i in range(len(test)):
					test[i] = test[i].strip()
					test2 = []
					for i in range(len(test)):
						if len(test[i]) > 0:
							test2.append(test[i])
					stats_dic["Speaks"] = ", ".join(test2)

		language = stats_dic.get("Speaks", "")
		try:
			language = self.verify(language)
		except:
			language = ""

		location = stats_dic.get("From", "")
		try:
			location = self.verify(location)
		except:
			location = ""

		pos_rating = stats_dic.get("Positive Rating", "")
		try:
			pos_rating = self.verify(pos_rating)
		except:
			pos_rating = ""

		ave_reponse_time = stats_dic.get("Avg. Response Time", "")
		try:
			ave_reponse_time = self.verify(ave_reponse_time)
		except:
			ave_reponse_time = ""

		try:
			starting_price = response.xpath('//span[@class="left-aligned js-str-currency js-price js-package-number-1"]/text()').extract_first()
			starting_price = starting_price.strip()
		except:
			try:
				starting_price = response.xpath('//ul[@class="packages-list"]//span/text()').extract_first()
				starting_price = starting_price.strip()
			except:
				starting_price = ""
		try:
			starting_price = self.verify(starting_price)
		except:
			starting_price = ""

		item = FiverrDataItem()

		item['category'] = category
		item['subcategory'] = subcategory
		item['title'] = title
		item['seller'] = seller
		item['rating'] = rating
		item['num_reviews'] = num_reviews 
		item['location'] = location 
		item['language'] = language
		item['pos_rating'] = pos_rating 
		item['ave_reponse_time'] = ave_reponse_time
		item['starting_price'] = starting_price 
		item['url'] = url 

		yield item

		













