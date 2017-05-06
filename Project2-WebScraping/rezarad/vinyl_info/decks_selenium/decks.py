from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import random
import csv

# choose a web driver
driver = webdriver.Chrome()

# create a csv file with data headers
csv_file = open('decks.csv', 'wb')
writer  = csv.writer(csv_file)
writer.writerow(['artist', 'release', 'tracks', 'label_cat', 'genre', 'price', 'release_date', 'available'])

# load into the sorted chart table
driver.get("https://www.decks.de/decks-sess/workfloor/lists/list.php?wo=ten&nowstyle=zz")

page_num = 1
while True:
    try:
        print "Scraping Page Number " + str(page_num)
		page_num = page_num + 1

        releases = driver.find_element_by_xpath('//span[@class = "txt_titel"]/text()').text

        for release in releases:
            release_info = {}

            artist = driver.find_element_by_xpath('//a[@class = "txt_artist"]/text()').text
            tracks = driver.find_element_by_xpath('//span[@class = "soundtxt"]//text()').text
            label_cat = driver.find_element_by_xpath('//span[@class = "labeltxt"]/text()').text
            genre = driver.find_element_by_xpath('//a[@class = "txt_styles"]/text()').text
            price= driver.find_element_by_xpath('//div[@class = "preisschild"]//text()').text
            release_date = driver.find_element_by_xpath('//span[@class = "txt_date"][1]/text()').text
            available = driver.find_element_by_xpath('//td/div/img[1]/@src').text

            review_dict['artist'] = artist
			review_dict['release'] = release
			review_dict['tracks'] = tracks
			review_dict['label_cat'] = label_cat
			review_dict['genre'] = genre
             review_dict['price'] = price
             review_dict['release_date'] = release_date
             review_dict['available'] = available
   			writer.writerow(release_info.values())

		# Locate the next button on the page.
        next_button  = driver.find_element_by_xpath('//a[@class="next"]')
        next_button.click()
        time.sleep(random.random()*12)


# assert "Decks" in driver.title
# elem = driver.find_element_by_name("q")
# elem.clear()
# elem.send_keys("pycon")
# elem.send_keys(Keys.RETURN)
# assert "No results found." not in driver.page_source
# driver.close()
