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

driver.get("https://www.verizonwireless.com/smartphones/samsung-galaxy-s7")

# Get csv
f = open('verizon.csv','w')
f.write('title,review\n')
# Page index used to keep track of where we are.
index = 1
while True:
	try:
		print "Scraping Page number " + str(index)
		index = index + 1
		# Find the device name
		# Check the documentation here: http://selenium-python.readthedocs.io/locating-elements.html
		# Once you locate the element, you can use 'element.text' to return its string. 

		brand = driver.find_element_by_xpath('//section[@id="device-name-wrapper"]/h1/span[1]').text
		device = driver.find_element_by_xpath('//section[@id="device-name-wrapper"]/h1/span[2]').text
		device = brand + ' ' + device

		# Find all the reviews. The find_elements function will return a list of selenium select elements.
#		reviews = driver.find_element_by_xpath('//section[@id="reviews"]/h1/span[2]').text
                reviews = driver.find_elements_by_xpath('//*[@id="BVRRContainer"]/div/div/div/div/ol/li')
#                //*[@id="BVRRContainer"]/div/div/div/div/ol/li[1]/div/div[1]/div/div[2]/div/div/div[1]/p
#                //*[@id="BVRRContainer"]/div/div/div/div/ol/li[2]/div/div[1]/div/div[2]/div/div/div[1]/p

		# To test the xpath, you can comment out the following code in the try statement and print the length of reviews.
		# Iterate through the list and find the details of each review.
		for review in reviews:
			# Initialize an empty dictionary for each review
			#review_dict = {}
			# Use Xpath to locate the title, content, username, date.
			# To get the attribute instead of the text of each element, use 'element.get_attribute()'
			title = review.find_element_by_xpath('.//div[@class="bv-content-title-container"]//h4').text
                        text = review.find_element_by_xpath('.//div[@class="bv-content-summary-body-text"]//p').text
                        print title
                        print text
                        line = '"' + title +'"' + ',' +'"' + text + '"' + '\n'
                        f.write(line)
                        #review_dict['title']=title
                       # review_dict['text']=text

			# Your code here

		# Locate the next button on the page. Then call 'button.click()' to really click it.
       	        button = driver.find_element_by_xpath('//*[@id="BVRRContainer"]/div/div/div/div/div[3]/div/ul/li[2]/a')
                button.click()
                time.sleep(2)
		
	except Exception as e:
		print e
		driver.close()
                f.close()
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
	
