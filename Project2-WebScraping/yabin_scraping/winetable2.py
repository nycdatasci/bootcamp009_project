#!/bin/python
#-*- conding:utf-8 -*-
from scrapy import Spider
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import csv

# Windows users need to specify the path to chrome driver you just downloaded.
# driver = webdriver.Chrome('path\to\where\you\download\the\chromedriver')
driver = webdriver.Chrome()

print 'test'

driver.get("http://www.winemag.com/?s=&drink_type=wine&page=1")

csv_file = open('reviews.csv', 'wb')
writer = csv.writer(csv_file)
writer.writerow(['category', 'appellation', 'name','variety','price','bottle_size','points','winery','description','alcohol'])
# Page index used to keep track of where we are.


def verify(content):
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



index = 1


while True:
	try:
		print ("Scraping Page number " + str(index))
		index = index + 1
		# Find the device name


		# Find all the reviews.

		reviews = []
		i=0
		for link in driver.find_elements_by_xpath('//a[@class="review-listing"]'):
			url  = link.get_attribute("href")
			reviews.append(url)

		for review in reviews:
			# Initialize an empty dictionary for each review
			driver.get(review)
			time.sleep(3)
			review_dict = {}
			# Use Xpath to locate the title, content, username, date.
			name = driver.find_element_by_xpath('//div[@class="article-title"]').text
			name = verify(name)
			points = driver.find_element_by_xpath('//span[@id="points"]').text
			points = verify(points)
			price = driver.find_element_by_xpath('//div[@class="info medium-9 columns"]/span/span').text[0:4]
			#date = driver.find_element_by_xpath('.//div[@class="bv-content-datetime"]//meta[@itemprop="datePublished"]').get_attribute('content')
			price = verify(price)

			#designation = driver.find_element_by_class_name('//*[@id="review"]/div[2]/div[2]/div[2]/div[1]/ul[1]/li[2]/div[2]/span/span').text
			#designation= verify(designation)

			#appellation = driver.find_element_by_xpath('//*[@id="review"]/div[2]/div[2]/div[2]/div[1]/ul[1]/li[4]/div[2]/span').text

			#appellation get all the data 
			# winery get the data , dont want buy now
			appellation = driver.find_elements_by_xpath('//div[@class="info medium-9 columns"]/span/a')[-1]
			appellation = appellation.text
			appellation=verify(appellation)
			variety  = driver.find_element_by_xpath('//div[@class="info medium-9 columns"]/span/a').text
			variety = verify(variety)


			winery = driver.find_elements_by_xpath('//*[@id="review"]/div[2]/div[2]/div[2]/div[1]/ul[1]/li/div[2]/span/span/a')[-1]
			#winery = driver.find_elements_by_xpath('//ul[@class="primary-info"]/li')[-1]
			#winery = winery.find_element_by_xpath('.//a').text
			winery = winery.text
			winery=verify(winery)

			list_wine = driver.find_elements_by_xpath('//div[@class="info small-9 columns"]/span/span')
			for i in range(len(list_wine)):
				if i == 0:
					alcohol = list_wine[i].text
				if i == 1:
					bottle_size = list_wine[i].text
				if i == 2:
					category = list_wine[i].text
			alcohol = verify(alcohol)
			bottle_size = verify(bottle_size)
			category = verify(category)
			description = driver.find_element_by_xpath('//p[@class="description"]').text
			description=verify(description)


			review_dict['name'] = name
			review_dict['points'] = points
			review_dict['price'] = price
			#review_dict['designation'] = designation
			review_dict['appellation'] = appellation
			review_dict['winery'] = winery
			review_dict['variety'] = variety
			review_dict['alcohol'] = alcohol
			review_dict['bottle_size'] = bottle_size
			review_dict['category'] = category
			review_dict['description'] = description
	
			writer.writerow(review_dict.values())
	
		driver.execute_script('window.history.go(-30)')
		button = driver.find_element_by_id("next-page")
		button.click()
		time.sleep(2)
		i+=1
		if i==1:
			break
	except Exception as e:
		print (e)
		csv_file.close()
		driver.close()
		break
		


	# Better solution using Explicit Waits in selenium: http://selenium-python.readthedocs.io/waits.html?highlight=element_to_be_selected#explicit-waits

	# try:
	# 	wait_review = WebDriverWait(driver, 10)
	# 	reviews = wait_review.until(EC.presence_of_all_elements_located((By.XPATH, 
	# 								'//ol[@class="bv-content-list bv-content-list-Reviews bv-focusable"]/li')))
	# 	print index
	# 	print 'review ok'
	# 	# reviews = driver.find_elements_by_xpath('//ol[@class="bv-content-list bv-content-list-Reviews bv-focusable"]/li')

	# 	wait_button = WebDriverWait(driver, 10)
	# 	button = wait_button.until(EC.element_to_be_clickable((By.XPATH, 
	# 								'//div[@class="bv-content-list-container"]//span[@class="bv-content-btn-pages-next"]')))
	# 	print 'button ok'
	# 	# button = driver.find_element_by_xpath('//span[@class="bv-content-btn-pages-next"]')
	# 	button.click()
	# except Exception as e:
	# 	print e
	# 	driver.close()
	# 	break


