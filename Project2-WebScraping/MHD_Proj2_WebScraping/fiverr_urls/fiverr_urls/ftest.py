# Website we want to scrape is: https://www.verizonwireless.com/smartphones/samsung-galaxy-s7/
# The documentatio of selenium is here: http://selenium-python.readthedocs.io/index.html

# Please follow the instructions below to setup the environment of selenium
# Step #1
# Windows users: download the chromedriver from here: https://chromedriver.storage.googleapis.com/index.html?path=2.27/
# Mac users: Install homebrew: http://brew.sh/
#			 Then run 'brew install chromedriver' on the terminal
#
# Step #2
# Windows users: open Anaconda prompt and run 'conda install -c conda-forge selenium=3.0.2'
# Mac users: open Terminal and run 'pip install selenium'

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import csv

# Windows users need to specify the path to chrome driver you just downloaded.
# driver = webdriver.Chrome('path\to\where\you\download\the\chromedriver')
driver = webdriver.Chrome()

driver.get("https://www.fiverr.com/categories/graphics-design/sample-business-cards-design?source=gallery-listing")


# Page index used to keep track of where we are.

for x in range(5):
	try:
		print "Scraping Item " 
		vendors = driver.find_elements_by_xpath('//a[@itemprop="url"]')
		#print vendors

		url_list = []

		for vendor in vendors:
			url_list.append(vendor.get_attribute("href"))

		print url_list

		button = driver.find_element_by_xpath('//a[@class="link-no-style js-next  js-report-to-aux-data"]')
		button.click()
		time.sleep(5)

		#print url_list

		#print names.text
		#print names.find_elements_by_css_selector('a').get_attribute('href')
		

		#print names.driver.find_elements_by_xpath('.//a[@class="gig-link-main js-gig-card-imp-data"]')

		#for name in names:
		#	button = review.find_element_by_xpath('//li[@class="bv-content-pagination-buttons-item bv-content-pagination-buttons-item-next"]')
	 	#	button.click()
		# device = driver.find_element_by_xpath('//section[@id="device-name-wrapper"]/h1/span[2]').text
		# device = brand + ' ' + device
		# #print device

		# # Find all the reviews. The find_elements function will return a list of selenium select elements.
		# reviews = driver.find_elements_by_xpath('//ol[@class="bv-content-list bv-content-list-Reviews bv-focusable"]/li')
		# print len(reviews)
		

		# # To test the xpath, you can comment out the following code in the try statement and print the length of reviews.
		# # Iterate through the list and find the details of each review.
		# X = 1

		# for review in reviews:
		# # 	# Initialize an empty dictionary for each review
		#  	review_dict = {}
		# # 	# Use Xpath to locate the title, content, username, date.
		# # 	# To get the attribute instead of the text of each element, use 'element.get_attribute()'
		 	
		#  	try:
		# 	 	title = review.find_element_by_xpath('.//div[@class="bv-content-title-container"]//h4').text
		# 	 	print title
		# 	except:
		# 		title = ""

		# 	try:
		# 	 	content = review.find_element_by_xpath('.//div[@class="bv-content-summary-body-text"]//p').text 
		# 	 	#print content
		# 	except:
		# 	 	content = ""
			

		# 	# Your code here

		# # Locate the next button on the page. Then call 'button.click()' to really click it.
	# 	button = driver.find_element_by_xpath('//li[@class="bv-content-pagination-buttons-item bv-content-pagination-buttons-item-next"]')
	# 	button.click()
		
	# except Exception as e:
	# 	print e
	# 	driver.close()
	# 	break


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
	except Exception as e:
		print e
		driver.close()
		break
	