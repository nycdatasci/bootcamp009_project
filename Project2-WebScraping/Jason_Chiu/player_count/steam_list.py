# Website we want to scrape is: https://www.verizonwireless.com/smartphones/samsung-galaxy-s7/
# The documentatio of selenium is here: http://selenium-python.readthedocs.io/index.html

# Please follow the instructions below to
# Step #1
# Windows users: download the chromedriver from here: https://chromedriver.storage.googleapis.com/index.html?path=2.27/
# Mac users: Install homebrew: http://brew.sh/
#			 Then run 'brew install chromedriver' on the terminal
#
# Step #2
# Install selenium package using 'pip install selenium' or anaconda gui interface.

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import csv

# Windows users need to specify the path to chrome driver you just downloaded.
# driver = webdriver.Chrome('path\to\where\you\download\the\chromedriver')
driver = webdriver.Chrome()

driver.get("https://steamdb.info/graph/")

csv_file = open('users1.csv', 'wb')
writer = csv.writer(csv_file)
writer.writerow(['app_id', 'title', 'current', 'day', 'all_time'])
# Page index used to keep track of where we are.

while True:
    try:
        listings = driver.find_elements_by_xpath('.//table[@id="table-apps"]//tr[@class="app"]')
        for listing in listings:
            list_dict = {}
            app_id = listing.find_element_by_xpath('.//td[2]/a').text
            app_id = app_id.encode('ascii', 'ignore')
            title = listing.find_element_by_xpath('.//td[3]').text
            title = title.encode('ascii', 'ignore')
            print title
            current = listing.find_element_by_xpath('.//td[4]').get_attribute("data-sort")
            print current
            day = listing.find_element_by_xpath('.//td[5]').text
            all_time = listing.find_element_by_xpath('.//td[6]').text
            list_dict["app_id"] = app_id
            list_dict["title"] = title
            list_dict["current"] = current
            list_dict["day"] = day
            list_dict["all_time"] = all_time
            writer.writerow(list_dict.values())
        button = driver.find_element_by_xpath('//*[@id="table-apps"]//tr[@class="show-other no-sort"]/td')
        button.click()
    except Exception as e:
		print e
		csv_file.close()
		driver.close()
		break


#index = 1
#while True:
#	try:
#		print "Scraping Page number " + str(index)
#		index = index + 1
#		# Find the device name
#		brand = driver.find_element_by_xpath('//section[@id="device-name-wrapper"]/h1/span[1]').text
#		device = driver.find_element_by_xpath('//section[@id="device-name-wrapper"]/h1/span[2]').text
#		device = brand + ' ' + device

		# Find all the reviews.
#		reviews = driver.find_elements_by_xpath('//ol[@class="bv-content-list bv-content-list-Reviews bv-focusable"]/li')
#		for review in reviews:
		# Initialize an empty dictionary for each review
#			review_dict = {}
#			# Use Xpath to locate the title, content, username, date.
#			title = review.find_element_by_xpath('.//div[@class="bv-content-title-container"]//h4').text
#			content = review.find_element_by_xpath('.//div[@class="bv-content-details-offset-on"]//p').text
#			username = review.find_element_by_xpath('.//div[@class="bv-content-meta"]//h3[@class="bv-author"]').text
#			date = review.find_element_by_xpath('.//div[@class="bv-content-datetime"]//meta[@itemprop="datePublished"]').get_attribute('content')

#			review_dict['title'] = title
#			review_dict['content'] = content
#			review_dict['username'] = username
#			review_dict['date'] = date
#			review_dict['device'] = device
 #  			writer.writerow(review_dict.values())

		# Locate the next button on the page.
#		button = driver.find_element_by_xpath('//span[@class="bv-content-btn-pages-next"]')
#		button.click()
#		time.sleep(2)
#	except Exception as e:
#		print e
#		csv_file.close()
#		driver.close()
#		break


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
