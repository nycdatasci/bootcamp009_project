# @author Scott Dobbins
# @version 0.0
# @date 2017-05-03 15:30

########### CURRENTLY NOT IN USE ####################

### import packages ###

# selenium
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# other python packages
import re
import csv
#import time
from datetime import datetime

# my helper package
import wait_helper


### constants ###
debug_mode_on = True
wait_mean = 2
wait_sd = 1


### set up web driver ###
driver = webdriver.Chrome()
URL = "https://camelcamelcamel.com/Canon-70-200mm-2-8L-Telephoto-Cameras/product/B0033PRWSW?context=browse"
driver.get(URL)


### set up csv files for writing ###

# product information file (scraped from camelcamelcamel directly)
products_csv = open('products.csv', 'wb')
products_writer = csv.writer(products_csv)

products_writer.writerow(['tag', 'date_time', 'title', 'is_updated',
'product_details', 'product_group', 'category', 'manufacturer', 'model', 'locale', 'list_price', 'EAN', 'UPC', 'SKU',
'last_update_scan', 'last_update_scan_units', 'last_tracked', 'last_tracked_units', 'Amazon_link',
'Amazon_has_data', 'Amazon_is_prime', 'Amazon_current_price', 'Amazon_current_price_date', 'Amazon_highest_price', 'Amazon_highest_price_date', 'Amazon_lowest_price', 'Amazon_lowest_price_date', 'Amazon_last5_dates', 'Amazon_last5_prices',
'new_has_data', 'new_is_prime', 'new_current_price', 'new_current_price_date', 'new_highest_price', 'new_highest_price_date', 'new_lowest_price', 'new_lowest_price_date', 'new_last5_dates', 'new_last5_prices',
'used_has_data', 'used_is_prime', 'used_current_price', 'used_current_price_date', 'used_highest_price', 'used_highest_price_date', 'used_lowest_price', 'used_lowest_price_date', 'used_last5_dates', 'used_last5_prices',])

# Amazon information file (scraped from Amazon ads on camelcamelcamel)
ads_csv = open('ads.csv', 'wb')
ads_writer = csv.writer(ads_csv)
ads_writer.writerow(['title', 'offer_price', 'list_price', 'is_prime', 'rating', 'num_reviews', 'date', 'time'])


### start crawl through one category ###

index = 1
index_max = 1

while(index <= index_max):
	try:
		if(debug_mode_on): print("Scraping Page number " + str(index))
		index = index + 1

		# make sure all elements are loaded (tests for ads since they're last to load)
		wait_ads = WebDriverWait(driver, 10)
		ads = wait_ads.until(EC.presence_of_all_elements_located((By.XPATH, '//div[@class="amzn-native-product amzn-native-product-asin-container"]/div')))

		if(debug_mode_on): print("ads loaded")

		### find content in the main scene ###

		# miscellaneous
		tag = re.search("([A-Za-z0-9]+)[?]", URL).group(1)
		print(tag)
		date_time = datetime.now()
		print(date_time)

		# # super header elements
		# is_updated = driver.find_element_by_xpath('//div[@class="flash usermsg warning"]') == None
		#
		# # top header elements
		# top_header = driver.find_element_by_xpath('//div[@class="col clearfix product_header_left_col"]')
		# title = top_header.find_element_by_xpath('./h1').text.strip()
		# # product_labels = top_header.find_element_by_xpath('./h1/span[@class="smalltext grey"][2]/a')
		# # for product_label in product_labels:
		# # 	abbreviation = product_label.get_attribute('href')[10:11]
		# # 	if(abbreviation == "pg"):
		# # 		product_group = product_label.text
		# # 	elif(abbreviation == "pc"):
		# # 		category = product_label.text
		# # 	elif(abbreviation == "mf"):
		# # 		manufacturer = product_label.text
		# Amazon_is_prime = top_header.find_element_by_xpath('.//span[@id="sss_amazon"]/a').text == "Prime"
		# new_is_prime = top_header.find_element_by_xpath('.//span[@id="sh_new"]/a').text == "Prime"
		# used_is_prime = top_header.find_element_by_xpath('.//span[@id="sh_used"]/a').text == "Prime"
		#
		# # top right header elements
		# top_right_header = driver.find_element_by_xpath('//div[@class="col clearfix product_header_right_col"]')
		# Amazon_link = top_right_header.find_element_by_xpath('.//div[@class="button retailer_link"]/').get_attribute('href')
		#
		# sleep(1)
		# # lower panel elements - Amazon price history
		# Amazon_has_data = driver.find_element_by_xpath('//div[@id="pricetabs"]/a[1]').get_attribute('href')[0] == "?"
		# Amazon_section = driver.find_element_by_xpath('//div[@id="section_amazon"]')
		# Amazon_current_price = Amazon_section.find_element_by_xpath('.//table[@width="100%"]//tr[1]/td[2]').text
		# Amazon_current_price_date = Amazon_section.find_element_by_xpath('.//table[@width="100%"]//tr[1]/td[3]').text
		# Amazon_highest_price = Amazon_section.find_element_by_xpath('.//table[@width="100%"]//tr[2]/td[2]').text
		# Amazon_highest_price_date = Amazon_section.find_element_by_xpath('.//table[@width="100%"]//tr[2]/td[3]').text
		# Amazon_lowest_price = Amazon_section.find_element_by_xpath('.//table[@width="100%"]//tr[3]/td[2]').text
		# Amazon_lowest_price_date = Amazon_section.find_element_by_xpath('.//table[@width="100%"]//tr[3]/td[3]').text
		# Amazon_history_list = Amazon_section.find_elements_by_xpath('.//table[@class="history_list product_pane"]/tr')
		# Amazon_last5_prices = []
		# Amazon_last5_dates = []
		# for item in Amazon_history_list:
		# 	Amazon_last5_dates.append(item.find_element_by_xpath('./td[1]')).text
		# 	Amazon_last5_prices.append(re.sub("$", "", item.find_element_by_xpath('./td[2]/span').text))
		#
		# sleep(1)
		# # lower panel elements - 3rd party new price history
		# new_has_data = driver.find_element_by_xpath('//div[@id="pricetabs"]/a[2]').get_attribute('href')[0] == "?"
		# new_section = driver.find_element_by_xpath('//div[@id="section_new"]')
		# new_current_price = new_section.find_element_by_xpath('.//table[@width="100%"]//tr[1]/td[2]').text
		# new_current_price_date = new_section.find_element_by_xpath('.//table[@width="100%"]//tr[1]/td[3]').text
		# new_highest_price = new_section.find_element_by_xpath('.//table[@width="100%"]//tr[2]/td[2]').text
		# new_highest_price_date = new_section.find_element_by_xpath('.//table[@width="100%"]//tr[2]/td[3]').text
		# new_lowest_price = new_section.find_element_by_xpath('.//table[@width="100%"]//tr[3]/td[2]').text
		# new_lowest_price_date = new_section.find_element_by_xpath('.//table[@width="100%"]//tr[3]/td[3]').text
		# new_history_list = new_section.find_elements_by_xpath('.//table[@class="history_list product_pane"]/tr')
		# new_last5_prices = []
		# new_last5_dates = []
		# for item in new_history_list:
		# 	new_last5_dates.append(item.find_element_by_xpath('./td[1]')).text
		# 	new_last5_prices.append(re.sub("$", "", item.find_element_by_xpath('./td[2]/span').text))
		#
		# sleep(1)
		# # lower panel elements - 3rd party used price history
		# used_has_data = driver.find_element_by_xpath('//div[@id="pricetabs"]/a[3]').get_attribute('href')[0] == "?"
		# used_section = driver.find_element_by_xpath('//div[@id="section_used"]')
		# used_current_price = used_section.find_element_by_xpath('.//table[@width="100%"]//tr[1]/td[2]').text
		# used_current_price_date = used_section.find_element_by_xpath('.//table[@width="100%"]//tr[1]/td[3]').text
		# used_highest_price = used_section.find_element_by_xpath('.//table[@width="100%"]//tr[2]/td[2]').text
		# used_highest_price_date = used_section.find_element_by_xpath('.//table[@width="100%"]//tr[2]/td[3]').text
		# used_lowest_price = used_section.find_element_by_xpath('.//table[@width="100%"]//tr[3]/td[2]').text
		# used_lowest_price_date = used_section.find_element_by_xpath('.//table[@width="100%"]//tr[3]/td[3]').text
		# used_history_list = used_section.find_elements_by_xpath('.//table[@class="history_list product_pane"]/tr')
		# used_last5_prices = []
		# used_last5_dates = []
		# for item in used_history_list:
		# 	used_last5_dates.append(item.find_element_by_xpath('./td[1]')).text
		# 	used_last5_prices.append(re.sub("$", "", item.find_element_by_xpath('./td[2]/span').text))
		#
		# sleep(1)
		# # lower panel elements - product details
		# product_details = driver.find_elements_by_xpath('//table[@class="product_fields"]')
		# product_group = product_details.find_element_by_xpath('./tr[1]/td[2]/a').text
		# category = product_details.find_element_by_xpath('./tr[2]/td[2]/a').text
		# manufacturer = product_details.find_element_by_xpath('./tr[3]/td[2]/a').text
		# model = product_details.find_element_by_xpath('./tr[4]/td[2]/a').text
		# locale = product_details.find_element_by_xpath('./tr[5]/td[2]/a').text
		# list_price = product_details.find_element_by_xpath('./tr[6]/td[2]/a').text
		# EAN = product_details.find_element_by_xpath('./tr[7]/td[2]/a').text
		# UPC = product_details.find_element_by_xpath('./tr[8]/td[2]/a').text
		# SKU = product_details.find_element_by_xpath('./tr[9]/td[2]/a').text
		# last_up = ''.split(product_details.find_element_by_xpath('./tr[10]/td[2]/a').text, ' ')
		# last_update_scan = int(last_up[0])
		# last_update_scan_units = last_up[1]
		# last_tr = ''.split(product_details.find_element_by_xpath('./tr[11]/td[2]/a').text, ' ')
		# last_tracked = int(last_tr[0])
		# last_tracked_units = last_tr[1]

		# make dictionary
		product_dict = {}

		product_dict['tag'] = tag
		product_dict['date_time'] = date_time
		# product_dict['title'] = title
		# product_dict['is_updated'] = is_updated
		# product_dict['Amazon_is_prime'] = Amazon_is_prime
		# product_dict['new_is_prime'] = new_is_prime
		# product_dict['used_is_prime'] = used_is_prime
		# product_dict['Amazon_link'] = Amazon_link
		# product_dict['Amazon_has_data'] = Amazon_has_data
		# product_dict['Amazon_current_price'] = Amazon_current_price
		# product_dict['Amazon_current_price_date'] = Amazon_current_price_date
		# product_dict['Amazon_highest_price'] = Amazon_highest_price
		# product_dict['Amazon_highest_price_date'] = Amazon_highest_price_date
		# product_dict['Amazon_lowest_price'] = Amazon_lowest_price
		# product_dict['Amazon_lowest_price_date'] = Amazon_lowest_price_date
		# product_dict['Amazon_last5_dates'] = Amazon_last5_dates
		# product_dict['Amazon_last5_prices'] = Amazon_last5_prices
		# product_dict['new_has_data'] = new_has_data
		# product_dict['new_current_price'] = new_current_price
		# product_dict['new_current_price_date'] = new_current_price_date
		# product_dict['new_highest_price'] = new_highest_price
		# product_dict['new_highest_price_date'] = new_highest_price_date
		# product_dict['new_lowest_price'] = new_lowest_price
		# product_dict['new_lowest_price_date'] = new_lowest_price_date
		# product_dict['new_last5_dates'] = new_last5_dates
		# product_dict['new_last5_prices'] = new_last5_prices
		# product_dict['used_has_data'] = used_has_data
		# product_dict['used_current_price'] = used_current_price
		# product_dict['used_current_price_date'] = used_current_price_date
		# product_dict['used_highest_price'] = used_highest_price
		# product_dict['used_highest_price_date'] = used_highest_price_date
		# product_dict['used_lowest_price'] = used_lowest_price
		# product_dict['used_lowest_price_date'] = used_lowest_price_date
		# product_dict['used_last5_dates'] = used_last5_dates
		# product_dict['used_last5_prices'] = used_last5_prices
		# product_dict['product_details'] = product_details
		# product_dict['product_group'] = product_group
		# product_dict['category'] = category
		# product_dict['manufacturer'] = manufacturer
		# product_dict['model'] = model
		# product_dict['locale'] = locale
		# product_dict['list_price'] = list_price
		# product_dict['EAN'] = EAN
		# product_dict['UPC'] = UPC
		# product_dict['SKU'] = SKU
		# product_dict['last_update_scan'] = last_update_scan
		# product_dict['last_update_scan_units'] = last_update_scan_units
		# product_dict['last_tracked'] = last_tracked
		# product_dict['last_tracked_units'] = last_tracked_units

		products_writer.writerow(product_dict.values())

		# ### find content in the ads pane ###
		# ads_panel = driver.find_elements_by_xpath('//div[@class="amzn-native-products-list"]')
		# for ad in ads_panel:
		# 	ad_text = ad.find_element_by_xpath('.//span[@class="amzn-native-product-title-text"]').text
		# 	ad_prices = ad.find_elements_by_xpath('.//div[@class="amzn-native-product-price"]')
		# 	ad_offer_price = ad_prices.find_element_by_xpath('./span[@class="amzn-native-product-offer-price"]').text
		# 	ad_list_price = ad_prices.find_element_by_xpath('./span[@class="amzn-native-product-list-price"]').text
		# 	ad_is_prime = ad_prices.find_element_by_xpath('./span[@class="amzn-sprite amzn-native-product-prime"]').get_attribute('style') != ""
		# 	ad_ratings = ad.find_element_by_xpath('.//div[@class="amzn-native-product-rating"]')
		# 	ad_rating_text = ad_ratings.find_element_by_xpath('./span[@class="amzn-native-product-stars-holder amzn-sprite"]').get_attribute('style')
		# 	ad_rating = int(re.search(" ([0-9]+)% ", ad_rating_text).group(1))/20.0
		# 	ad_review_count_text = ad_ratings.find_element_by_xpath('./span[@class="amzn-native-product-review-count"]').text
		# 	ad_review_count = int(re.sub("[()]", "", ad_review_count_text))
		# 	ad_product_title = title
		# 	ad_product_page = Amazon_link
		# 	ad_product_link = ad.find_element_by_xpath('.//a[@class="amzn-native-product-title"]').get_attribute('href')
		# 	ad_date_time = datetime.now()
		#
		# 	ad_dict = {}
		#
		# 	ad_dict['ad_text'] = ad_text
		# 	ad_dict['ad_offer_price'] = ad_offer_price
		# 	ad_dict['ad_list_price'] = ad_list_price
		# 	ad_dict['ad_is_prime'] = ad_is_prime
		# 	ad_dict['ad_rating'] = ad_rating
		# 	ad_dict['ad_review_count'] = ad_review_count
		# 	ad_dict['ad_product_title'] = ad_product_title
		# 	ad_dict['ad_product_page'] = ad_product_page
		# 	ad_dict['ad_product_link'] = ad_product_link
		# 	ad_dict['ad_date_time'] = ad_date_time
		#
		# 	ads_writer.writerow(ad_dict.values())
		#
		# ### wait for next button to click ###
		#
		# # wait_button = WebDriverWait(driver, 10)
		# # button = wait_button.until(EC.element_to_be_clickable((By.XPATH,
		# # 							'//div[@class="bv-content-list-container"]//span[@class="bv-content-btn-pages-next"]')))
		# # if(debug_mode_on): print('button ok')
		#
		# # wait random log-normal time #
		# wait_log_normal(wait_mean, wait_sd)
		# # button.click()


	except Exception as e:
		print e
		products_csv.close()
		ads_csv.close()
		driver.close()
		break

products_csv.close()
ads_csv.close()
# driver.close()
