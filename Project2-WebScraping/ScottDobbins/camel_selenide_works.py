# @author Scott Dobbins
# @version 0.51
# @date 2017-07-06 20:00


### next steps ###
# make it take the login and download sales-rank graph as well


### import packages ###

# selenium
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# other python packages
import csv
import re
import urllib
import time
from datetime import datetime
from random import random as rng

# my helper package
from wait_helper import wait_log_normal


### constants ###

# master controls
debug_mode_on = True
wait_mean = 1
wait_sd = 0.5
zero_y_axis = True
img_width = 8092
img_height = 6144
include_legend = False
time_period = "1 year"
page_index_max = 100
initial_delay = 10
product_category = "Personal+Computers"
start_page = 1
data_rewrite = False

# helper terms
columns = ['ASIN', 'date_time', 'title', 'link', 'group', 'category', 'manufacturer', 'price_Amazon', 'price_new', 'price_used']
csv_directory = "../csv/"
images_directory = "../images/"
img_infix_Amazon = "/Amazon.png"
img_infix_new = "/new.png"
img_infix_used = "/used.png"
img_infix_salesRank = "/sales-rank.png"
chart_root = "https://charts.camelcamelcamel.com/us/"
img_name_suffix_Amazon = "_Amazon.png"
img_name_suffix_new = "_new.png"
img_name_suffix_used = "_used.png"
img_name_suffix_salesRank = "_salesRank.png"
products_root = "https://camelcamelcamel.com/products"
products_infix = "?pc="
if(start_page != 1):
		products_page_suffix = "&p=" + str(start_page)
else:
	products_page_suffix = ""

# dependents on master controls
if(zero_y_axis):
	img_infix_zero = "&zero=1"
else:
	img_infix_zero = "&zero=0"
img_infix_width = "&w=" + str(img_width)
img_infix_height = "&h=" + str(img_height)
if(include_legend):
	img_infix_legend = "&legend=1"
else:
	img_infix_legend = "&legend=0"
if(time_period == "1 year"):
	img_infix_timePeriod = "&tp=1y"
elif(time_period == "all"):
	img_infix_timePeriod = "&tp=all"

img_URL_suffix_Amazon = img_infix_Amazon + "?force=1" + img_infix_zero + img_infix_width + img_infix_height + img_infix_legend + "&ilt=1" + img_infix_timePeriod + "&fo=0&lang=en"
img_URL_suffix_new = img_infix_new + "?force=1" + img_infix_zero + img_infix_width + img_infix_height + img_infix_legend + "&ilt=1" + img_infix_timePeriod + "&fo=0&lang=en"
img_URL_suffix_used = img_infix_used + "?force=1" + img_infix_zero + img_infix_width + img_infix_height + img_infix_legend + "&ilt=1" + img_infix_timePeriod + "&fo=0&lang=en"
img_URL_suffix_salesRank = img_infix_salesRank + "?force=1" + img_infix_zero + img_infix_width + img_infix_height + img_infix_legend + "&ilt=1" + img_infix_timePeriod + "&fo=0&lang=en"

if(data_rewrite):
	csv_open_parameters = 'wb'
else:
	csv_open_parameters = 'ab'


### set up csv files for writing ###

# product information file (scraped from camelcamelcamel directly)
products_csv = open((csv_directory + "products.csv"), csv_open_parameters)
products_writer = csv.writer(products_csv)

if(data_rewrite):
	products_writer.writerow(columns)


### set up web driver ###
driver = webdriver.Chrome()
URL = products_root + products_infix + product_category + products_page_suffix
driver.get(URL)

time.sleep(initial_delay)

page_index = start_page
product_index = 0

while(page_index <= page_index_max):

	print("Scraping " + product_category + " page: " + str(page_index))

	products_waiter = WebDriverWait(driver, 900)
	wait_products = products_waiter.until(EC.presence_of_all_elements_located((By.XPATH, '//div[@id="products_list"]//tr')))

	products_table = driver.find_element_by_xpath('//div[@id="products_list"]')
	products = products_table.find_elements_by_xpath('.//tr')


	for product in products:
		if(rng() < 0.1):
			if(debug_mode_on): print("random log-normal wait")
			wait_log_normal(wait_mean, wait_sd)
		product_index += 1
		print("Capturing product #" + str(product_index))
		date_time = datetime.now()
		title = product.find_element_by_xpath('.//div[@class="product_title"]/a').text.encode('ascii', 'ignore')
		link = product.find_element_by_xpath('.//div[@class="product_title"]/a').get_attribute('href')
		ASIN = re.search("([A-Za-z0-9]+)[?]", link).group(1)
		breadcrumbs = product.find_elements_by_xpath('.//div[@class="breadcrumbs"]/a')
		group = ""
		category = ""
		manufacturer = ""
		for breadcrumb in breadcrumbs:
			result = re.search("[&]([a-z]{2})[=]", breadcrumb.get_attribute('href'))
			if(bool(result)):
				tag = result.group(1)
				if(tag == "pg"):
					group = breadcrumb.text.encode('ascii', 'ignore')
				elif(tag == "mf"):
					manufacturer = breadcrumb.text.encode('ascii', 'ignore')
			else:
				category = breadcrumb.text.encode('ascii', 'ignore')
		# group = breadcrumbs.find_element_by_xpath('./a[1]').text.encode('ascii', 'ignore')
		# category = breadcrumbs.find_element_by_xpath('./a[2]').text.encode('ascii', 'ignore')
		# manufacturer = breadcrumbs.find_element_by_xpath('./a[3]').text.encode('ascii', 'ignore')
		price_Amazon = re.sub("[$,]", "", product.find_element_by_xpath('.//div[@class="price_amazon"]').text)
		price_new = re.sub("[$,]", "", product.find_element_by_xpath('.//div[@class="price_new"]').text)
		price_used = re.sub("[$,]", "", product.find_element_by_xpath('.//div[@class="price_used"]').text)

		product_dict = {}
		product_dict['ASIN'] = ASIN
		product_dict['date_time'] = date_time
		product_dict['title'] = title
		product_dict['link'] = link
		product_dict['group'] = group
		product_dict['category'] = category
		product_dict['manufacturer'] = manufacturer
		if(bool(re.search("[ -\-/:-~]+", price_Amazon))):
			product_dict['price_Amazon'] = float('NaN')
		else:
			product_dict['price_Amazon'] = float(price_Amazon)
		if(bool(re.search("[ -\-/:-~]+", price_new))):
			product_dict['price_new'] = float('NaN')
		else:
			product_dict['price_new'] = float(price_new)
		if(bool(re.search("[ -\-/:-~]+", price_used))):
			product_dict['price_used'] = float('NaN')
		else:
			product_dict['price_used'] = float(price_used)

		products_writer.writerow([product_dict[column] for column in columns])

		urllib.urlretrieve((chart_root + ASIN + img_URL_suffix_Amazon), (images_directory + ASIN + img_name_suffix_Amazon))
		urllib.urlretrieve((chart_root + ASIN + img_URL_suffix_new), (images_directory + ASIN + img_name_suffix_new))
		urllib.urlretrieve((chart_root + ASIN + img_URL_suffix_used), (images_directory + ASIN + img_name_suffix_used))
		# urllib.urlretrieve((chart_root + ASIN + img_URL_suffix_salesRank), (images_directory + ASIN + img_name_suffix_salesRank))# currently still says it needs a login even after logging in
		wait_log_normal(wait_mean, wait_sd)

	page_index += 1

	wait_log_normal(wait_mean, wait_sd)

	next_page_button = driver.find_element_by_xpath('//div[@id="products_filter"]/div/a[last()]')
	next_page_button.click()


products_csv.close()
driver.close()
